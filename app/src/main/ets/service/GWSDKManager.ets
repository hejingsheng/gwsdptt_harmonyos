import {
  GWCurrentGroupNotifyBean,
  GWDuplexBean,
  GWKickoutNotifyBean,
  GWMemberInfoBean,
  GWMsgBaseBean,
  GWMsgBean,
  gwsdPttSdk,
  GWTempGroupNotifyBean,
  MemberInfo,
  MsgContent} from 'gwsdptt_sdk'
import { GWLoginResultBean } from 'gwsdptt_sdk';
import { GWGroupBean, GWGroupListBean } from 'gwsdptt_sdk';
import { GWJoinGroupBean } from 'gwsdptt_sdk';
import { GWType } from 'gwsdptt_sdk'
import { common } from '@kit.AbilityKit';
import hilog from '@ohos.hilog';
import AppAbility from '../appability/AppAbility';
import { systemDateTime } from '@kit.BasicServicesKit';
import { GWPttUserInfo } from './GWPttUserInfo';
import { HashMap, JSON, List } from '@kit.ArkTS';
import { OfflineEventBean } from './OfflineEventBean';
import { MsgContentBean } from '../db/MsgContentBean';
import { MsgConversationBean } from '../db/MsgConversationBean';
import { MsgDB } from '../db/MsgDB';
import { NotifiDataBean } from './NotifiDataBean';
import { NotificationService } from './NotificationService';
import { CallManager } from './CallManager';
import { router } from '@kit.ArkUI';
import { AudioCallParam, PttCallParam } from './CallParam';

export interface GWSDKPttEngngObserer {
  onPttEvent: (event: number, data: string, data1: number) => void;
  onMsgEvent: (event: number, data: string) => void;
}

'user shared'
export class GWSDKManager {

  static INSTANCE:GWSDKManager = new GWSDKManager();
  static getInstance() {
    return GWSDKManager.INSTANCE;
  }

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'GWSDKManager=%{public}s', msg);
  }

  private context:common.UIAbilityContext|undefined;
  private imei?:string;
  private iccid?:string;
  private userInfo:GWPttUserInfo;
  private groupMap:HashMap<number, GWGroupBean> = new HashMap();
  private grouplist:List<GWGroupBean> = new List();
  private memberlist:List<MemberInfo> = new List();
  private haveStartMsgService:boolean = false;

  private pttObserver:GWSDKPttEngngObserer|undefined = undefined;

  private constructor() {
    gwsdPttSdk.pttInit(this.onPttEvent.bind(this), this.onMsgEvent.bind(this));
    gwsdPttSdk.pttConfigServer(0, '43.250.33.13', 23003);
    gwsdPttSdk.pttConfigServer(1, '43.250.33.13', 51883);
    gwsdPttSdk.pttConfigServer(2, '123.60.212.171', 50001);
    //this.log('current sdk version:'+gwsdPttSdk.pttGetVersion());
    this.userInfo = new GWPttUserInfo();
  }

  public setContext(ctx: common.UIAbilityContext) {
    this.context = ctx;
  }

  public getContext() :common.UIAbilityContext|undefined {
    return this.context;
}

  public registerPttObserver(observer:GWSDKPttEngngObserer|undefined) {
    this.pttObserver = observer;
  }

  public getUserInfo() : GWPttUserInfo {
    return this.userInfo;
  }

  public getVersion() : string {
    return gwsdPttSdk.pttGetVersion();
  }

  public login(account:string, password:string, imei:string, iccid:string) {
    gwsdPttSdk.pttLogin(account, password, '12345', '54321');
    this.imei = imei;
    this.iccid = iccid;
    this.userInfo!.account = account;
    this.userInfo!.password = password;
    this.userInfo!.online = false;
  }

  public joinGroup(gid: number, type: number) {
    gwsdPttSdk.pttJoinGroup(gid, type);
  }

  public queryGroup() {
    gwsdPttSdk.pttQueryGroup();
  }

  public queryMember(gid: number, type: number) {
    gwsdPttSdk.pttQueryMember(gid,type);
  }

  public tempGroup(uids: Uint32Array, num: number) {
    gwsdPttSdk.pttTempGroup(uids, num);
  }

  public startSpeak(){
    gwsdPttSdk.pttSpeak(0, systemDateTime.getTime(false));
  }

  public stopSpeak(){
    gwsdPttSdk.pttSpeak(1, systemDateTime.getTime(false));
  }

  public fullDuplex(uid: number, action: number){
    gwsdPttSdk.pttDuplexCall(uid,action);
  }

  public mutePttSpk(mute: boolean) {
    let open:number = mute?0:1;
    gwsdPttSdk.pttVoiceToggle(0, open);
  }

  public mutePttMic(mute: boolean) {
    let open:number = mute?0:1;
    gwsdPttSdk.pttVoiceToggle(1, open);
  }

  public loginOut(){
    gwsdPttSdk.pttLogout();
  }

  public getWeather(cellid: number, lac: number, mode: number, mcc: string, mnc: string) {
    gwsdPttSdk.pttGetWeather(cellid, lac, mode, mcc, mnc);
  }

  public hasMsgPermission() : boolean {
    if (this.userInfo.message || this.userInfo.video || this.userInfo.silent) {
      return true;
    }
    return false;
  }

  public hasDuplexCallPermission() : boolean {
    if (this.userInfo.call) {
      return true;
    }
    return false;
  }

  public isOnline() : boolean {
    return this.userInfo.online;
  }

  public startMsgService(gids: number[], types: number[], num: number) {
    if (!this.haveStartMsgService) {
      let gidArray: Uint32Array = new Uint32Array(gids);
      let typeArray: Uint32Array = new Uint32Array(types);
      gwsdPttSdk.pttRegOfflineMsg(gidArray, typeArray, num, 0);
      this.haveStartMsgService = true;
    }
  }

  public createMsgBean1(sendId: string, sendNm: string, recvtype: number, remoteid: string, remotenm: string, msgtype: number) : GWMsgBean {
    let gwMsgBean:GWMsgBean = new GWMsgBean();
    gwMsgBean.from = sendId;
    gwMsgBean.type = msgtype;
    let ts = Math.floor(systemDateTime.getTime(false)/1000);
    gwMsgBean.time = ts;
    let msg:MsgContent = new MsgContent();
    msg.content = '';
    msg.sendId = sendId;
    msg.sendName = sendNm;
    msg.sendUType = GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER;
    msg.receiveId = remoteid;
    msg.receiveName = remotenm;
    msg.receiveUType = recvtype;
    msg.time = ts;
    msg.msgType = msgtype;
    gwMsgBean.data = msg;
    return gwMsgBean;
  }

  public createMsgBean(recvtype:number, remoteid: number, remotenm: string, msgtype: number) : GWMsgBean {
    let gwMsgBean:GWMsgBean = new GWMsgBean();
    gwMsgBean.from = this.userInfo.id.toString();
    gwMsgBean.type = msgtype;
    let ts = Math.floor(systemDateTime.getTime(false)/1000);
    gwMsgBean.time = ts;
    let msg:MsgContent = new MsgContent();
    msg.content = '';
    msg.sendId = this.userInfo.id.toString();
    msg.sendName = this.userInfo.name;
    msg.sendUType = GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER;
    msg.receiveId = remoteid.toString();
    msg.receiveName = remotenm;
    msg.receiveUType = recvtype;
    msg.time = ts;
    msg.msgType = msgtype;
    gwMsgBean.data = msg;
    return gwMsgBean;
  }

  public sendMsg(msg: GWMsgBean) {
    let content:string = msg.data.content;
    let ts = msg.time * 1000;
    if (msg.type !== GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT) {
      content = msg.data.url;
    }
    gwsdPttSdk.pttSendMsg(this.userInfo.id, this.userInfo.name, msg.data.receiveUType, parseInt(msg.data.receiveId),
      msg.data.receiveName, msg.type, content, msg.data.thumbUrl, 0, '', 0, ts, 1, 1);
  }

  public getGroupList() : List<GWGroupBean> {
    return this.grouplist;
  }

  public getMemberList() : List<MemberInfo> {
    return this.memberlist;
  }

  private onPttEvent(event:number, data:string, data1:number) {
    this.log('recv ptt event=' + event + ' data=' + data);
    if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_LOGIN) {
      let json = JSON.parse(data);
      let gwLoginResultBean:GWLoginResultBean = (json as GWLoginResultBean);
      if (gwLoginResultBean.result === 0) {
        this.log(gwLoginResultBean.name+" login success");
        this.userInfo!.name = gwLoginResultBean.name || '';
        this.userInfo!.id = gwLoginResultBean.uid as number;
        this.userInfo!.online = true;
        this.userInfo!.defaultGid = gwLoginResultBean.defaultGid as number;
        this.userInfo!.message = gwLoginResultBean.message as boolean;
        this.userInfo!.call = gwLoginResultBean.call as boolean;
        this.userInfo!.video = gwLoginResultBean.video as boolean;
        this.userInfo!.silent = gwLoginResultBean.silent as boolean;
        gwsdPttSdk.pttHeart(100, '5g');
        this.startTimer();
        this.queryGroup();
      }
      this.context?.eventHub.emit('login', gwLoginResultBean.result);
    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_QUERY_GROUP) {
      let json = JSON.parse(data);
      let gwGroupListBean:GWGroupListBean = (json as GWGroupListBean);
      if (gwGroupListBean.result === 0) {
        let groups: List<GWGroupBean> = gwGroupListBean.groups as List<GWGroupBean>;
        if (this.grouplist === null) {
          this.grouplist = new List();
        }
        this.groupMap.clear();
        this.grouplist.clear();
        for (let grouplistElement of groups) {
          if (grouplistElement.type != 16) {
            grouplistElement.type = 3;
          }
          this.grouplist.add(grouplistElement);
        }
        let msg_groups:number[] = [];
        let msg_groups_type:number[] = [];
        let i:number = 0;
        let joingid:number = 0;
        let joingtype:number = 0;
        for (let grouplistElement of this.grouplist) {
          if (grouplistElement.gid === this.userInfo!.defaultGid) {
            joingid = grouplistElement.gid;
            joingtype = grouplistElement.type;
          }
          this.groupMap.set(grouplistElement.gid, grouplistElement);
          msg_groups[i] = grouplistElement.gid;
          msg_groups_type[i] = grouplistElement.type;
          i++;
        }
        if (this.userInfo!.message || this.userInfo!.video || this.userInfo!.silent) {
          this.startMsgService(msg_groups, msg_groups_type, this.grouplist.length)
        }
        if (joingid === 0) {
          joingid = this.grouplist.get(0).gid;
          joingtype = this.grouplist.get(0).type;
        }
        if (this.userInfo!.getCurrentGroupGid() === 0) {
          this.joinGroup(joingid, joingtype);
        }
      }
    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_JOIN_GROUP) {
      let json = JSON.parse(data);
      let gwJoinGroupBean:GWJoinGroupBean = (json as GWJoinGroupBean);
      if (gwJoinGroupBean.result === 0) {
        this.log('join group success');
        this.userInfo?.setCurrentGroupGid(gwJoinGroupBean.gid);
        this.userInfo?.setCurrentGroupPriority(gwJoinGroupBean.priority);
        this.userInfo?.setCurrentGroupName(this.groupMap.get(gwJoinGroupBean.gid).name);
        this.userInfo?.setCurrentGroupType(this.groupMap.get(gwJoinGroupBean.gid).type);
      }
    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_QUERY_MEMBER) {
      let json = JSON.parse(data);
      let gwMemberInfoBean:GWMemberInfoBean = (json as GWMemberInfoBean);
      if (gwMemberInfoBean.result === 0) {
        let members: List<MemberInfo> = gwMemberInfoBean.members as List<MemberInfo>;
        this.memberlist.clear();
        for (let membersElement of members) {
          this.memberlist.add(membersElement);
        }
      }
    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_REQUEST_MIC) {

    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_TMP_GROUP_ACTIVE) {

    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_TMP_GROUP_PASSIVE) {
      let json = JSON.parse(data);
      let gwTempGroupNotifyBean: GWTempGroupNotifyBean = (json as GWTempGroupNotifyBean);
      if (gwTempGroupNotifyBean.name !== undefined && gwTempGroupNotifyBean.name !== '') {
        CallManager.getInstance().checkCallStateSwitch(CallManager.CALL_STATE_PTT_TMP_GROUP_CALL).then((result) => {
          if (result.interrupt) {
            let pttCallparam = new PttCallParam(gwTempGroupNotifyBean.uid, gwTempGroupNotifyBean.name, GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER, false);
            router.pushUrl({
              url: 'pages/PttCall',
              params: pttCallparam
            })
          }
          else {
            let uids:Uint32Array = new Uint32Array(1);
            uids[0] = 0;
            this.tempGroup(uids, 0);
          }
        });
      }
      else {
        this.log('remote release tmp group');
      }
    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_DUPLEX) {
      let json = JSON.parse(data);
      let gwDuplexBean: GWDuplexBean = (json as GWDuplexBean);
      if (gwDuplexBean.result === 0) {
        if (gwDuplexBean.status === GWType.GW_DUPLEX_STATUS.GW_PTT_DUPLEX_STATUS_INVIET) {
          if (gwDuplexBean.uid !== 0) {
            CallManager.getInstance().checkCallStateSwitch(CallManager.CALL_STATE_AUDIO_VIDEO_CALL).then((data)=>{
              if (data.notice) {
                // wake screen
                let notifiDataBean = new NotifiDataBean();
                notifiDataBean.recvNm = gwDuplexBean.name;
                notifiDataBean.recvId = gwDuplexBean.uid;
                notifiDataBean.type = NotifiDataBean.NOTIFI_TYPE_AUDIO_CALL;
              }
              else {
                if (data.interrupt) {
                  if (data.oldstate === CallManager.CALL_STATE_PTT_TMP_GROUP_CALL) {
                    setTimeout(() => {
                      // goto audio call
                      let audioCallparam = new AudioCallParam(gwDuplexBean.uid, gwDuplexBean.name, false);
                      router.pushUrl({
                        url: 'pages/AudioCall',
                        params: audioCallparam
                      })
                    }, 500);
                  }
                  else {
                    // goto audio call
                    let audioCallparam = new AudioCallParam(gwDuplexBean.uid, gwDuplexBean.name, false);
                    router.pushUrl({
                      url: 'pages/AudioCall',
                      params: audioCallparam
                    })
                  }
                }
                else {
                  // need notice
                  let notifiDataBean = new NotifiDataBean();
                  notifiDataBean.recvNm = gwDuplexBean.name;
                  notifiDataBean.recvId = gwDuplexBean.uid;
                  notifiDataBean.type = NotifiDataBean.NOTIFI_TYPE_AUDIO_CALL;
                  notifiDataBean.forceNotice = true;

                }
              }
            });
          }
        }
        else if (gwDuplexBean.status === GWType.GW_DUPLEX_STATUS.GW_PTT_DUPLEX_STATUS_END) {

        }
      }
    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_LOGOUT) {
      this.log("logout");
      this.offline(OfflineEventBean.OFFLINE_REASON_LOGOUT_CODE, '');
    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_KICKOUT) {
      let json = JSON.parse(data);
      let gwKickoutNotifyBean:GWKickoutNotifyBean = (json as GWKickoutNotifyBean);
      this.log("kickout");
      this.offline(OfflineEventBean.OFFLINE_REASON_KICKOUT_CODE, gwKickoutNotifyBean.reason);
    }
    else if (event === GWType.GW_PTT_EVENT.GW_PTT_EVENT_CURRENT_GROUP) {
      let json = JSON.parse(data);
      let gwCurrentGroupNotifyBean:GWCurrentGroupNotifyBean = (json as GWCurrentGroupNotifyBean);
      if (gwCurrentGroupNotifyBean.result === 0) {
        this.userInfo.setCurrentGroupGid(gwCurrentGroupNotifyBean.gid);
        this.userInfo.setCurrentGroupName(gwCurrentGroupNotifyBean.name);
        this.userInfo.setCurrentGroupType(0);
        if (gwCurrentGroupNotifyBean.reason === 'return') {
          this.userInfo.setCurrentGroupPriority(this.userInfo.lastpriority);
        } else {
          this.userInfo.lastpriority = this.userInfo.getCurrentGroupPriority();
          this.userInfo.setCurrentGroupPriority(-1);
        }
      }
    }
    else if (event == GWType.GW_PTT_EVENT.GW_PTT_EVENT_SPEAK) {

    }
    else if (event == GWType.GW_PTT_EVENT.GW_PTT_EVENT_PLAY_DATA) {
      this.log("recv pcm data="+data1);
      return;
    }
    else if (event == GWType.GW_PTT_EVENT.GW_PTT_EVENT_LOSTMIC) {
      this.log("speak too long time stop record");
    }
    else if (event == GWType.GW_PTT_EVENT.GW_PTT_EVENT_GROUP_OPERATE) {

    }
    else if (event == GWType.GW_PTT_EVENT.GW_PTT_EVENT_QUERY_DISPATCH) {

    }
    else if (event == GWType.GW_PTT_EVENT.GW_PTT_EVENT_FRIEND_OPERATE) {

    }
    else if (event == GWType.GW_PTT_EVENT.GW_PTT_EVENT_QUERY_CHAT_GRP) {

    }
    else if (event == GWType.GW_PTT_EVENT.GW_PTT_EVENT_CHAT_GRP_DETAIL) {

    }
    else {
      this.log('error happen');
      this.offline(OfflineEventBean.OFFLINE_REASON_ERROR_CODE, '');
    }
    if (this.pttObserver) {
      this.pttObserver.onPttEvent(event, data, data1);
    }
  }

  private reloginTimer:number = -1;
  private offline(code: number, reason: string) {
    this.userInfo.online = false;
    this.stopTimer();
    this.haveStartMsgService = false;
    this.context?.eventHub.emit('offline', code, reason);
    if (code !== OfflineEventBean.OFFLINE_REASON_LOGOUT_CODE) {
      this.log('need login again');
      if (this.reloginTimer === -1) {
        this.reloginTimer = setInterval(() => {
          if (!this.userInfo.online) {
            gwsdPttSdk.pttLogin(this.userInfo.account, this.userInfo.password, this.imei, this.iccid);
          } else {
            clearInterval(this.reloginTimer);
            this.reloginTimer = -1;
          }
        }, 5 * 1000);
      }
    }
  }

  private onMsgEvent(status:number, msg:string, length:number) {
    this.log('recv msg status=' + status);
    if (status === GWType.GW_MSG_STATUS.GW_MSG_STATUS_ERROR) {
      this.haveStartMsgService = false;
    }
    if (status === GWType.GW_MSG_STATUS.GW_MSG_STATUS_DATA) {
      let json = JSON.parse(msg);
      let gwMsgBaseBean: GWMsgBaseBean = (json as GWMsgBaseBean);
      if (gwMsgBaseBean.type == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT
        || gwMsgBaseBean.type == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_PHOTO
        || gwMsgBaseBean.type == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VOICE
        || gwMsgBaseBean.type == GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO) {
        this.log('recv msg data');
        if (gwMsgBaseBean.from === this.userInfo.id.toString()) {
          this.log('recv self msg data drop it');
        }
        else {
          let gwMsgBean: GWMsgBean = (json as GWMsgBean);
          MsgDB.getINSTANCE().saveMsgContent(this.userInfo.id.toString(), gwMsgBean)
            .then((msg:MsgContentBean) => {
              MsgDB.getINSTANCE().saveOrUpdateConv(msg, false)
                .then((conv:MsgConversationBean) => {
                  this.context?.eventHub.emit('recvmsg', msg);
                  this.context?.eventHub.emit('recvconv', conv);
                  // send notification
                  let notifidata:NotifiDataBean = new NotifiDataBean();
                  notifidata.sendNm = msg.senderNm;
                  notifidata.recvNm = msg.recvNm;
                  notifidata.recvId = msg.convId;
                  notifidata.msgType = msg.msgType;
                  notifidata.content = msg.content;
                  notifidata.recvType = msg.recvType;
                  NotificationService.getInstance().sendNotification(notifidata);
              });
          });
        }
      }
    }
  }

  private timerId:number = 0;
  private startTimer() {
    this.timerId = setInterval(() => {
      gwsdPttSdk.pttHeart(100, '5g');
    }, 50*1000);
  }

  private stopTimer() {
    if (this.timerId != 0) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }
  }

}