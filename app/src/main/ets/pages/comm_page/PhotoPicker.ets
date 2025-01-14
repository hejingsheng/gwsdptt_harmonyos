import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct NotificationDemo {
  publishNotification() {

    let notificationRequest: notificationManager.NotificationRequest = { // 描述通知的请求
      id: 1, // 通知ID
      content: { // 通知内容
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT, // 普通文本类型通知
        normal: { // 基本类型通知内容
          title: '通知内容标题',
          text: '通知内容详情'
        }
      }
    }
    notificationManager.addSlot(notificationManager.SlotType.SOCIAL_COMMUNICATION).then(() => {
      notificationManager.publish(notificationRequest).then(() => { // 发布通知
        console.info('publish success');
      }).catch((err: Error) => {
        console.error(`publish failed,message is ${err}`);
      });
    }).catch((err: BusinessError) => {

    });

  }

  build() {
    Column() {
      Button('发送通知')
        .onClick(() => {
          let context = getContext(this) as common.UIAbilityContext;
          notificationManager.isNotificationEnabled().then((data: boolean) => {
            if(!data){
              notificationManager.requestEnableNotification(context).then(() => {
                this.publishNotification();
              }).catch((err : BusinessError) => {
                if(1600004 == err.code){

                } else {

                }
              });
            }
            else {
              this.publishNotification();
            }
          }).catch((err : BusinessError) => {

          });

        })
    }
    .width('100%')
  }
}
