import { ChatFileMsgParam, ChatFileUploadParam } from "./ChatModel";
import { common } from "@kit.AbilityKit";
import { taskpool } from "@kit.ArkTS";
import AppAbility from "../appability/AppAbility";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { http } from "@kit.NetworkKit";
import { JSON } from '@kit.ArkTS';
import StringUtils from "../utils/StringUtils";
import { FileUploadResBean } from "./FileUploadResBean";
import { BusinessError } from "@kit.BasicServicesKit";
import { GWSDKManager } from "./GWSDKManager";
import { MsgDB } from "../db/MsgDB";
import { MsgContentBean } from "../db/MsgContentBean";
import { MsgConversationBean } from "../db/MsgConversationBean";
import { copyFile } from '../utils/Utils';

@Concurrent
async function fileUpload(fileUploadParam:ChatFileUploadParam): Promise<ChatFileUploadParam|null> {
  let upload: ChatFileUploadParam|null = null;
  let uri = fileUploadParam.filepath;
  let thumburi = fileUploadParam.filepathThumb;
  let mediaType = '';
  if (fileUploadParam.filetype == ChatFileMsgParam.VIDEO_FILE_TYPE) {
    mediaType = 'video/mp4';
  }
  else if (fileUploadParam.filetype == ChatFileMsgParam.VOICE_FILE_TYPE) {
    mediaType = 'audio/mp3';
  }
  else if (fileUploadParam.filetype == ChatFileMsgParam.PHOTO_FILE_TYPE) {
    mediaType = 'image/jpg';
  }
  else {
    mediaType = 'image/jpg';
  }
  let multdata:Array<http.MultiFormData> = [];
  multdata[0] = {
    name:'file1',
    contentType: mediaType,
    filePath: uri,
  };
  if (thumburi !== '') {
    multdata[0] = {
      name:'file2',
      contentType: 'image/jpg',
      filePath: thumburi,
    };
  }
  const httpRequest = http.createHttp();
  await httpRequest.request('http://120.46.155.150:5001/app/chat/msg/upload2',{
    method:http.RequestMethod.POST,
    header:{
      'Content-Type': 'multipart/form-data',
      'Connection':'keep-alive'
    },
    expectDataType:http.HttpDataType.ARRAY_BUFFER,
    multiFormDataList: multdata,
  }).then((data: http.HttpResponse) => {
    if (data.responseCode !== 200) {
      // http upload error
      return;
    }
    let res = StringUtils.arrayBuffer2String(data.result as ArrayBuffer);
    try {
      let json = JSON.parse(res);
      let fileuploadres: FileUploadResBean = json as FileUploadResBean;
      if (fileuploadres.status === 200) {
        let fileurl = fileuploadres.data!.file1!.url;
        upload = new ChatFileUploadParam(fileurl, fileUploadParam.filetype, '');
        if (fileuploadres.data!.file2 !== undefined) {
          let url = fileuploadres.data!.file2!.url;
          upload.filepathThumb = url;
        }
      } else {
      }
    } catch (e) {
    }
  }).catch((err: BusinessError) => {
  });
  return upload;
}

export class ChatFileSendService {

  private static INSTANCE:ChatFileSendService = new ChatFileSendService();

  public static getINSTANCE() {
    return ChatFileSendService.INSTANCE;
  }

  private log(msg: string) {
    hilog.info(0x0000, AppAbility.TAG, 'Chat=%{public}s', msg);
  }

  private constructor() {
  }

  public async sendMediaFile(chatFileMsgParam:ChatFileMsgParam, context: common.UIAbilityContext) {
    this.log('sendMediaFile1');
    let fileUploadParam:ChatFileUploadParam = new ChatFileUploadParam(copyFile(chatFileMsgParam.filepath, context),
      chatFileMsgParam.filetype, copyFile(chatFileMsgParam.filepathThumb, context));
    let fileUploadTask: taskpool.Task = new taskpool.Task(fileUpload, fileUploadParam);
    this.log('sendMediaFile2');
    await taskpool.execute(fileUploadTask).then((res: object) => {
      this.log('file send task end');
      if (res !== null) {
        let uploadResult = res as ChatFileUploadParam;
        let msg = chatFileMsgParam.msg;
        msg.data.url = uploadResult.filepath;
        if (uploadResult.filepathThumb !== '') {
          msg.data.thumbUrl = uploadResult.filepathThumb;
        }
        GWSDKManager.getInstance().sendMsg(msg);
        msg.data.url = chatFileMsgParam.filepath;
        msg.data.thumbUrl = chatFileMsgParam.filepathThumb;
        MsgDB.getINSTANCE().saveMsgContent(msg.data.sendId, msg)
          .then((msg: MsgContentBean) => {
            MsgDB.getINSTANCE().saveOrUpdateConv(msg, false)
              .then((conv: MsgConversationBean) => {
                context.eventHub.emit('recvmsg', msg);
                context.eventHub.emit('recvconv', conv);
              })
          });
      }
      else {
        this.log('sendMediaFile3');
      }
    });
  }

}