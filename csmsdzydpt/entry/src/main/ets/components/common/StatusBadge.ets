import { getStatusLabel, getStatusColor } from '../../constants/OrderStatus';

@Component
export struct StatusBadge {
  @Prop status: string = '';

  build() {
    Text(getStatusLabel(this.status))
      .fontSize(11)
      .fontColor('#FFFFFF')
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      .borderRadius(4)
      .backgroundColor(getStatusColor(this.status));
  }
}
