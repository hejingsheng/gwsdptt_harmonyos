import { hilog } from "@kit.PerformanceAnalysisKit";
import AppAbility from "../appability/AppAbility";
import { NotifiDataBean } from "./NotifiDataBean";
import { common, WantAgent, wantAgent } from "@kit.AbilityKit";
import { window } from "@kit.ArkUI";
import { GWType } from "gwsdptt_sdk";
import { notificationManager } from "@kit.NotificationKit";
import { systemDateTime } from "@kit.BasicServicesKit";

export class NotificationService {

  static INSTANCE:NotificationService = new NotificationService();
  static getInstance() {
    return NotificationService.INSTANCE;
  }

  private constructor() {
  }

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'NotificationService=%{public}s', msg);
  }

  private isAppForceground = true;
  private imagestr:string = '';
  private voicestr:string = '';
  private videostr:string = '';
  public init(context: common.UIAbilityContext) {
    context.windowStage.on('windowStageEvent', (data) => {
      if (data === window.WindowStageEventType.SHOWN || data === window.WindowStageEventType.ACTIVE) {
        this.isAppForceground = true;
      }
      else if (data === window.WindowStageEventType.HIDDEN || data === window.WindowStageEventType.INACTIVE) {
        this.isAppForceground = false;
      }
    });
    this.imagestr = context.resourceManager.getStringSync($r('app.string.chat_imtype_img'));
    this.voicestr = context.resourceManager.getStringSync($r('app.string.chat_imtype_voice'));
    this.videostr = context.resourceManager.getStringSync($r('app.string.chat_imtype_video'));
  }

  public isForeground() : boolean {
    return this.isAppForceground;
  }

  public sendNotification(notifiDataBean: NotifiDataBean) {
    if (!this.isAppForceground || notifiDataBean.forceNotice) {
      this.log('app is background');
      this.showNotification(notifiDataBean);
    }
    else {
      this.log('app is not background');
    }
  }

  private async showNotification(notifiDataBean: NotifiDataBean) {
    let title:string = '';
    let content:string = '';
    let convNm = '';
    let type = notifiDataBean.type;
    if (type === NotifiDataBean.NOTIFI_TYPE_MSG) {
      if (notifiDataBean.recvType == GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER) {
        title = notifiDataBean.sendNm
        if (notifiDataBean.msgType == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT) {
          content = notifiDataBean.content;
        } else if (notifiDataBean.msgType == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_PHOTO) {
          content = this.imagestr;
        } else if (notifiDataBean.msgType == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VOICE) {
          content = this.voicestr;
        } else if (notifiDataBean.msgType == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO) {
          content = this.videostr;
        } else {
          content = notifiDataBean.content;
        }
        convNm = notifiDataBean.sendNm;
      } else {
        title = notifiDataBean.recvNm;
        if (notifiDataBean.msgType == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT) {
          content = notifiDataBean.sendNm + ":" + notifiDataBean.content;
        } else if (notifiDataBean.msgType == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_PHOTO) {
          content = notifiDataBean.sendNm + ":" + this.imagestr;
        } else if (notifiDataBean.msgType == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VOICE) {
          content = notifiDataBean.sendNm + ":" + this.voicestr;
        } else if (notifiDataBean.msgType == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO) {
          content = notifiDataBean.sendNm + ":" + this.videostr;
        } else {
          content = notifiDataBean.sendNm + ":" + notifiDataBean.content;
        }
        convNm = notifiDataBean.recvNm;
      }
    }
    else {
      // audio video call
    }
    this.log('send notice');
    let wantAgentObj: WantAgent|undefined = undefined;
    let autoDeletedTime :number|undefined = undefined;
    if (!notifiDataBean.forceNotice) {
      let wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: "com.gwsd.open_ptt",
            abilityName: "AppAbility"
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 100,
        extraInfo: {
          'type': 'Msg',
          'convId': notifiDataBean.recvId,
          'convNm': convNm,
          'convType': notifiDataBean.recvType
        }
      }
      wantAgentObj = await wantAgent.getWantAgent(wantAgentInfo);
      autoDeletedTime = undefined;
    }
    else {
      wantAgentObj = undefined;
      autoDeletedTime = 5000;
    }
    let notificationRequest: notificationManager.NotificationRequest = { // 描述通知的请求
      id: systemDateTime.getTime(false), // 通知ID
      groupName: 'Chat',
      content: { // 通知内容
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT, // 普通文本类型通知
        normal: { // 基本类型通知内容
          title: title,
          text: content
        }
      },
      notificationSlotType:notificationManager.SlotType.SOCIAL_COMMUNICATION,
    };
    if (autoDeletedTime !== undefined) {
      notificationRequest.autoDeletedTime = autoDeletedTime;
    }
    if (wantAgentObj !== undefined) {
      notificationRequest.wantAgent = wantAgentObj;
    }
    notificationManager.publish(notificationRequest).then(() => { // 发布通知
      this.log('publish success');
    }).catch((err: Error) => {

    });
  }
}