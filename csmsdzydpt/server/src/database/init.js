const { getDb } = require('./connection');
const bcrypt = require('bcryptjs');

function initDatabase() {
  const db = getDb();

  // Create tables
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      username    TEXT NOT NULL UNIQUE,
      password    TEXT,
      nickname    TEXT,
      phone       TEXT,
      avatar_url  TEXT,
      created_at  TEXT DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS listings (
      id                  INTEGER PRIMARY KEY AUTOINCREMENT,
      title               TEXT NOT NULL,
      description         TEXT,
      address             TEXT,
      city                TEXT NOT NULL,
      latitude            REAL,
      longitude           REAL,
      room_type           TEXT NOT NULL CHECK(room_type IN ('entire_place','private_room','shared_room')),
      max_guests          INTEGER DEFAULT 1,
      bedrooms            INTEGER DEFAULT 1,
      beds                INTEGER DEFAULT 1,
      bathrooms           INTEGER DEFAULT 1,
      amenities           TEXT DEFAULT '[]',
      base_price          REAL NOT NULL,
      cleaning_fee        REAL DEFAULT 0,
      service_fee_percent REAL DEFAULT 10.0,
      avg_rating          REAL DEFAULT 0,
      review_count        INTEGER DEFAULT 0,
      images              TEXT DEFAULT '[]',
      host_name           TEXT,
      host_avatar         TEXT,
      nearby              TEXT DEFAULT '[]',
      status              TEXT DEFAULT 'available',
      created_at          TEXT DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS availability (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      listing_id   INTEGER NOT NULL REFERENCES listings(id),
      date         TEXT NOT NULL,
      price        REAL,
      is_available INTEGER DEFAULT 1,
      UNIQUE(listing_id, date)
    );

    CREATE TABLE IF NOT EXISTS orders (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id       INTEGER NOT NULL REFERENCES users(id),
      listing_id    INTEGER NOT NULL REFERENCES listings(id),
      check_in      TEXT NOT NULL,
      check_out     TEXT NOT NULL,
      guests        INTEGER DEFAULT 1,
      nights        INTEGER NOT NULL,
      base_total    REAL NOT NULL,
      cleaning_fee  REAL DEFAULT 0,
      service_fee   REAL DEFAULT 0,
      total_price   REAL NOT NULL,
      status        TEXT DEFAULT 'pending_payment'
                    CHECK(status IN ('pending_payment','confirmed','checked_in','completed','cancelled')),
      paid_at       TEXT,
      cancelled_at  TEXT,
      checked_in_at TEXT,
      completed_at  TEXT,
      created_at    TEXT DEFAULT (datetime('now')),
      updated_at    TEXT DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS reviews (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users(id),
      listing_id INTEGER NOT NULL REFERENCES listings(id),
      order_id   INTEGER NOT NULL UNIQUE REFERENCES orders(id),
      rating     INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
      content    TEXT,
      images     TEXT DEFAULT '[]',
      created_at TEXT DEFAULT (datetime('now'))
    );
  `);

  // Migration: add password column if missing (for existing databases)
  try {
    const tableInfo = db.prepare("PRAGMA table_info(users)").all();
    const hasPassword = tableInfo.some(col => col.name === 'password');
    if (!hasPassword) {
      db.exec("ALTER TABLE users ADD COLUMN password TEXT");
      console.log('Migrated: added password column to users table');
    }
    // Set default password for existing users that don't have one
    const defaultPwd = bcrypt.hashSync('123456', 10);
    db.prepare('UPDATE users SET password = ? WHERE password IS NULL').run(defaultPwd);
  } catch (err) {
    console.log('Migration check skipped:', err.message);
  }

  // Seed users
  const userCount = db.prepare('SELECT COUNT(*) as count FROM users').get().count;
  if (userCount === 0) {
    const defaultPassword = bcrypt.hashSync('123456', 10);
    const insertUser = db.prepare(
      'INSERT INTO users (username, password, nickname, phone, avatar_url) VALUES (?, ?, ?, ?, ?)'
    );
    insertUser.run('demo_user', defaultPassword, '旅行达人小王', '13800138000', '');
    insertUser.run('host_zhang', defaultPassword, '房东张先生', '13900139000', '');
    insertUser.run('guest_li', defaultPassword, '李女士', '13700137000', '');
  }

  // Seed listings
  const listingCount = db.prepare('SELECT COUNT(*) as count FROM listings').get().count;
  if (listingCount === 0) {
    const insertListing = db.prepare(`
      INSERT INTO listings (title, description, address, city, latitude, longitude,
        room_type, max_guests, bedrooms, beds, bathrooms, amenities, base_price,
        cleaning_fee, service_fee_percent, avg_rating, review_count, images,
        host_name, host_avatar, nearby, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const listings = [
      {
        title: '西湖边的温馨小屋',
        description: '位于西湖景区步行5分钟的独栋小院，独立卫生间，免费WiFi，配有厨房和洗衣机。周边有众多餐厅和便利店，交通便利，距离地铁站步行仅需3分钟。房间装修温馨舒适，适合情侣度假或商务出行。',
        address: '杭州市西湖区龙井路88号',
        city: '杭州',
        latitude: 30.2395, longitude: 120.1350,
        room_type: 'entire_place', max_guests: 2, bedrooms: 1, beds: 1, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '洗衣机', '厨房', '热水器', '吹风机', '洗发水', '沐浴露']),
        base_price: 358, cleaning_fee: 50, service_fee_percent: 10,
        avg_rating: 4.8, review_count: 126,
        images: JSON.stringify(['/api/images/01.jpg', '/api/images/02.jpg', '/api/images/03.jpg']),
        host_name: '房东张先生', host_avatar: '',
        nearby: JSON.stringify([
          { name: '西湖', type: '景点', distance: '500m' },
          { name: '龙井村', type: '景点', distance: '1.2km' },
          { name: '地铁1号线', type: '交通', distance: '300m' },
          { name: '银泰百货', type: '购物', distance: '800m' },
          { name: '便利店', type: '生活', distance: '100m' }
        ]),
        status: 'available'
      },
      {
        title: '外滩景观公寓',
        description: '坐拥黄浦江一线江景的高端公寓，落地窗设计，可俯瞰外滩和陆家嘴天际线。全屋智能家居，配备高档床品和洗护用品。楼下就是外滩步道，周边高档餐厅林立。',
        address: '上海市黄浦区中山东一路18号',
        city: '上海',
        latitude: 31.2390, longitude: 121.4900,
        room_type: 'entire_place', max_guests: 4, bedrooms: 2, beds: 2, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '智能家居', '厨房', '洗衣机', '烘干机', '浴缸', '戴森吹风机', '投影仪']),
        base_price: 688, cleaning_fee: 100, service_fee_percent: 10,
        avg_rating: 4.9, review_count: 89,
        images: JSON.stringify(['/api/images/04.jpg', '/api/images/05.jpg', '/api/images/06.jpeg']),
        host_name: 'Linda', host_avatar: '',
        nearby: JSON.stringify([
          { name: '外滩', type: '景点', distance: '100m' },
          { name: '南京路步行街', type: '购物', distance: '500m' },
          { name: '地铁2号线', type: '交通', distance: '400m' },
          { name: '豫园', type: '景点', distance: '1.5km' }
        ]),
        status: 'available'
      },
      {
        title: '鼓浪屿海景民宿',
        description: '位于鼓浪屿岛上的海景民宿，步行可达日光岩和菽庄花园。房间采用地中海风格装修，配有观海阳台，每天清晨可欣赏海上日出。民宿提供免费早餐和下午茶。',
        address: '厦门市思明区鼓浪屿安海路35号',
        city: '厦门',
        latitude: 24.4480, longitude: 118.0680,
        room_type: 'private_room', max_guests: 2, bedrooms: 1, beds: 1, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '海景阳台', '免费早餐', '下午茶', '洗衣服务']),
        base_price: 288, cleaning_fee: 30, service_fee_percent: 8,
        avg_rating: 4.7, review_count: 203,
        images: JSON.stringify(['/api/images/07.jpg', '/api/images/08.jpg', '/api/images/09.jpeg']),
        host_name: '陈阿姨', host_avatar: '',
        nearby: JSON.stringify([
          { name: '日光岩', type: '景点', distance: '300m' },
          { name: '菽庄花园', type: '景点', distance: '600m' },
          { name: '龙头路小吃街', type: '餐饮', distance: '400m' },
          { name: '钢琴码头', type: '交通', distance: '800m' }
        ]),
        status: 'available'
      },
      {
        title: '成都太古里潮流公寓',
        description: '紧邻太古里商圈的现代风格公寓，工业风装修设计。步行可达IFS、春熙路，楼下就是地铁站。房间配有投影仪、游戏机和黑胶唱片机，非常适合年轻人入住体验。',
        address: '成都市锦江区大慈寺路28号',
        city: '成都',
        latitude: 30.6530, longitude: 104.0830,
        room_type: 'entire_place', max_guests: 3, bedrooms: 1, beds: 2, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '投影仪', '游戏机', '黑胶唱片机', '厨房', '洗衣机']),
        base_price: 328, cleaning_fee: 60, service_fee_percent: 10,
        avg_rating: 4.6, review_count: 67,
        images: JSON.stringify(['/api/images/10.jpeg', '/api/images/11.jpeg', '/api/images/12.jpeg']),
        host_name: '小陈', host_avatar: '',
        nearby: JSON.stringify([
          { name: '太古里', type: '购物', distance: '200m' },
          { name: 'IFS国际金融中心', type: '购物', distance: '500m' },
          { name: '春熙路', type: '购物', distance: '800m' },
          { name: '地铁2号线', type: '交通', distance: '300m' },
          { name: '大慈寺', type: '景点', distance: '100m' }
        ]),
        status: 'available'
      },
      {
        title: '三亚海棠湾度假别墅',
        description: '独栋别墅带私人泳池和花园，步行3分钟到海边。四间卧室可容纳8人，适合家庭聚会或朋友出游。配有全套厨房设备、烧烤架和户外用餐区，提供管家服务。',
        address: '三亚市海棠区海棠北路168号',
        city: '三亚',
        latitude: 18.3100, longitude: 109.7300,
        room_type: 'entire_place', max_guests: 8, bedrooms: 4, beds: 5, bathrooms: 3,
        amenities: JSON.stringify(['WiFi', '空调', '私人泳池', '花园', '厨房', '烧烤架', '管家服务', '免费停车', '洗衣机', '烘干机']),
        base_price: 1588, cleaning_fee: 200, service_fee_percent: 10,
        avg_rating: 5.0, review_count: 42,
        images: JSON.stringify(['/api/images/13.jpeg', '/api/images/14.jpeg', '/api/images/15.jpeg']),
        host_name: '王管家', host_avatar: '',
        nearby: JSON.stringify([
          { name: '海棠湾沙滩', type: '景点', distance: '300m' },
          { name: '免税店', type: '购物', distance: '2km' },
          { name: '蜈支洲岛码头', type: '交通', distance: '5km' }
        ]),
        status: 'available'
      },
      {
        title: '北京胡同四合院',
        description: '位于南锣鼓巷附近的传统四合院改造民宿，保留了老北京建筑风貌，融入现代化居住设施。院子里的石榴树和葡萄架充满生活气息，步行可达什刹海和后海酒吧街。',
        address: '北京市东城区南锣鼓巷胡同56号',
        city: '北京',
        latitude: 39.9370, longitude: 116.4030,
        room_type: 'private_room', max_guests: 2, bedrooms: 1, beds: 1, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '暖气', '院子', '自行车租赁', '茶具']),
        base_price: 428, cleaning_fee: 50, service_fee_percent: 10,
        avg_rating: 4.8, review_count: 178,
        images: JSON.stringify(['/api/images/16.jpeg', '/api/images/17.jpeg', '/api/images/18.jpeg']),
        host_name: '老刘', host_avatar: '',
        nearby: JSON.stringify([
          { name: '南锣鼓巷', type: '景点', distance: '50m' },
          { name: '什刹海', type: '景点', distance: '800m' },
          { name: '后海酒吧街', type: '娱乐', distance: '1km' },
          { name: '地铁6号线', type: '交通', distance: '500m' }
        ]),
        status: 'available'
      },
      {
        title: '广州珠江新城CBD公寓',
        description: '位于珠江新城核心地段的商务公寓，步行可达广州塔、花城广场。现代简约装修风格，配有人体工学办公桌椅和高速网络，非常适合商务出差人士。',
        address: '广州市天河区珠江新城华夏路16号',
        city: '广州',
        latitude: 23.1190, longitude: 113.3250,
        room_type: 'entire_place', max_guests: 2, bedrooms: 1, beds: 1, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '办公桌', '打印机', '咖啡机', '厨房', '洗衣机', '健身房']),
        base_price: 398, cleaning_fee: 60, service_fee_percent: 10,
        avg_rating: 4.5, review_count: 54,
        images: JSON.stringify(['/api/images/19.jpeg', '/api/images/20.jpeg', '/api/images/21.jpeg']),
        host_name: 'Alex', host_avatar: '',
        nearby: JSON.stringify([
          { name: '广州塔', type: '景点', distance: '1km' },
          { name: '花城广场', type: '景点', distance: '500m' },
          { name: '地铁APM线', type: '交通', distance: '300m' },
          { name: '高德置地广场', type: '购物', distance: '600m' }
        ]),
        status: 'available'
      },
      {
        title: '大理洱海湖畔客栈',
        description: '洱海边的白族风格客栈，每间房都能看到洱海和苍山。客栈提供自行车环湖、白族扎染体验等活动。院子里的多肉花园和猫是客栈的特色，适合放空发呆。',
        address: '大理市大理古城才村码头旁',
        city: '大理',
        latitude: 25.6100, longitude: 100.1700,
        room_type: 'private_room', max_guests: 2, bedrooms: 1, beds: 1, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '洱海景观', '自行车租赁', '扎染体验', '早餐', '茶室', '猫']),
        base_price: 258, cleaning_fee: 30, service_fee_percent: 8,
        avg_rating: 4.7, review_count: 312,
        images: JSON.stringify(['/api/images/22.jpeg', '/api/images/23.jpeg', '/api/images/24.jpeg']),
        host_name: '大理老杨', host_avatar: '',
        nearby: JSON.stringify([
          { name: '洱海', type: '景点', distance: '50m' },
          { name: '大理古城', type: '景点', distance: '1.5km' },
          { name: '苍山', type: '景点', distance: '3km' },
          { name: '才村码头', type: '交通', distance: '100m' }
        ]),
        status: 'available'
      },
      {
        title: '南京夫子庙秦淮河畔',
        description: '位于夫子庙景区核心位置，推窗即见秦淮河夜景。房间采用新中式装修风格，将传统文化与现代舒适完美结合。步行可达老门东、中华门，周边美食无数。',
        address: '南京市秦淮区夫子庙贡院街22号',
        city: '南京',
        latitude: 32.0200, longitude: 118.7900,
        room_type: 'entire_place', max_guests: 3, bedrooms: 1, beds: 2, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '秦淮河景观', '茶具', '汉服体验', '厨房']),
        base_price: 338, cleaning_fee: 50, service_fee_percent: 10,
        avg_rating: 4.6, review_count: 95,
        images: JSON.stringify(['/api/images/25.jpeg', '/api/images/26.jpeg', '/api/images/27.jpeg']),
        host_name: '金陵小周', host_avatar: '',
        nearby: JSON.stringify([
          { name: '夫子庙', type: '景点', distance: '100m' },
          { name: '秦淮河', type: '景点', distance: '50m' },
          { name: '老门东', type: '景点', distance: '800m' },
          { name: '地铁3号线', type: '交通', distance: '400m' }
        ]),
        status: 'available'
      },
      {
        title: '重庆解放碑江景民宿',
        description: '位于解放碑核心商圈的高层江景民宿，270度无遮挡观景窗可同时欣赏长江、嘉陵江和南山夜景。步行可达洪崖洞、长江索道，感受8D魔幻城市的魅力。',
        address: '重庆市渝中区解放碑八一路9号',
        city: '重庆',
        latitude: 29.5610, longitude: 106.5760,
        room_type: 'entire_place', max_guests: 4, bedrooms: 2, beds: 2, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '江景阳台', '厨房', '洗衣机', '投影仪', '火锅设备']),
        base_price: 388, cleaning_fee: 70, service_fee_percent: 10,
        avg_rating: 4.7, review_count: 143,
        images: JSON.stringify(['/api/images/28.jpeg', '/api/images/29.jpeg', '/api/images/30.jpeg']),
        host_name: '山城小伙', host_avatar: '',
        nearby: JSON.stringify([
          { name: '解放碑', type: '景点', distance: '200m' },
          { name: '洪崖洞', type: '景点', distance: '600m' },
          { name: '长江索道', type: '交通', distance: '800m' },
          { name: '八一好吃街', type: '餐饮', distance: '300m' }
        ]),
        status: 'available'
      },
      {
        title: '西安钟楼古城民宿',
        description: '位于西安城墙内的古城民宿，步行3分钟到钟楼和回民街。房间以唐代风格装饰，配有仿古家具和书法字画。民宿提供免费汉服租赁和古城导览服务。',
        address: '西安市碑林区钟楼西大街15号',
        city: '西安',
        latitude: 34.2610, longitude: 108.9420,
        room_type: 'private_room', max_guests: 2, bedrooms: 1, beds: 1, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '暖气', '汉服租赁', '古城导览', '茶室', '书法体验']),
        base_price: 268, cleaning_fee: 40, service_fee_percent: 8,
        avg_rating: 4.5, review_count: 167,
        images: JSON.stringify(['/api/images/31.jpeg', '/api/images/32.jpeg', '/api/images/33.jpeg']),
        host_name: '长安老赵', host_avatar: '',
        nearby: JSON.stringify([
          { name: '钟楼', type: '景点', distance: '300m' },
          { name: '回民街', type: '餐饮', distance: '200m' },
          { name: '城墙', type: '景点', distance: '500m' },
          { name: '地铁2号线', type: '交通', distance: '400m' }
        ]),
        status: 'available'
      },
      {
        title: '深圳湾科技园青年公寓',
        description: '位于深圳湾科技园附近的青年长租公寓，适合短期出差和过渡住宿。全屋智能家居系统，配有升降桌和人体工学椅。公共区域有健身房、咖啡厅和共享办公空间。',
        address: '深圳市南山区科技园南区深圳湾一路88号',
        city: '深圳',
        latitude: 22.5330, longitude: 113.9530,
        room_type: 'shared_room', max_guests: 1, bedrooms: 1, beds: 1, bathrooms: 1,
        amenities: JSON.stringify(['WiFi', '空调', '智能家居', '升降桌', '健身房', '咖啡厅', '共享办公', '洗衣房']),
        base_price: 168, cleaning_fee: 20, service_fee_percent: 5,
        avg_rating: 4.3, review_count: 78,
        images: JSON.stringify(['/api/images/34.jpeg', '/api/images/35.jpeg', '/api/images/36.jpeg']),
        host_name: '科技园小刘', host_avatar: '',
        nearby: JSON.stringify([
          { name: '深圳湾公园', type: '景点', distance: '1km' },
          { name: '万象天地', type: '购物', distance: '2km' },
          { name: '地铁2号线', type: '交通', distance: '500m' },
          { name: '深圳湾口岸', type: '交通', distance: '3km' }
        ]),
        status: 'available'
      }
    ];

    const insertMany = db.transaction((items) => {
      for (const l of items) {
        insertListing.run(
          l.title, l.description, l.address, l.city, l.latitude, l.longitude,
          l.room_type, l.max_guests, l.bedrooms, l.beds, l.bathrooms,
          l.amenities, l.base_price, l.cleaning_fee, l.service_fee_percent,
          l.avg_rating, l.review_count, l.images,
          l.host_name, l.host_avatar, l.nearby, l.status
        );
      }
    });

    insertMany(listings);
  }

  // Seed availability for next 90 days
  const availCount = db.prepare('SELECT COUNT(*) as count FROM availability').get().count;
  if (availCount === 0) {
    const listings = db.prepare('SELECT id, base_price FROM listings').all();
    const insertAvail = db.prepare(
      'INSERT OR IGNORE INTO availability (listing_id, date, price, is_available) VALUES (?, ?, ?, ?)'
    );

    const today = new Date();
    const seedAvail = db.transaction(() => {
      for (const listing of listings) {
        for (let i = 0; i < 90; i++) {
          const date = new Date(today);
          date.setDate(date.getDate() + i);
          const dateStr = date.toISOString().split('T')[0];

          // Weekend price surcharge
          const dayOfWeek = date.getDay();
          let priceMultiplier = 1.0;
          if (dayOfWeek === 5 || dayOfWeek === 6) priceMultiplier = 1.3; // Weekend
          const price = Math.round(listing.base_price * priceMultiplier);

          // Randomly make some dates unavailable (15% chance)
          const rand = Math.random();
          const isAvailable = rand > 0.15 ? 1 : 0;

          insertAvail.run(listing.id, dateStr, price, isAvailable);
        }
      }
    });
    seedAvail();
  }


  console.log('Database initialized successfully with seed data.');
}

function datetime() {
  return new Date().toISOString().replace('T', ' ').split('.')[0];
}

module.exports = { initDatabase };
