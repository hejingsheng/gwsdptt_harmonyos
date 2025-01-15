import { relationalStore } from '@kit.ArkData'; // 导入模块
import { GWMsgBean, GWType, MsgContent } from 'gwsdptt_sdk';
import { MsgContentBean } from './MsgContentBean';
import { MsgConversationBean } from './MsgConversationBean';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { STORE_CONFIG } from './DBManager';

function createTable(store: relationalStore.RdbStore, ifNotExists:boolean) {
  let constraint:string = ifNotExists? "IF NOT EXISTS ": "";
  let sql_create_convtable = "CREATE TABLE " + constraint + "\"tb_msg_conversation\" (" + //
    "\"_id\" INTEGER PRIMARY KEY AUTOINCREMENT ," + // 0: tab_Id
    "\"LOGIN_UID\" TEXT," + // 1: loginUId
    "\"CONV_ID\" INTEGER," + // 2: convId
    "\"CONV_TYPE\" INTEGER," + // 3: convType
    "\"CONV_NM\" TEXT," + // 4: convNm
    "\"MSG_CNT\" INTEGER," + // 5: msgCnt
    "\"MSG_UN_READ_CNT\" INTEGER," + // 6: msgUnReadCnt
    "\"LAST_MSG_ID\" INTEGER," + // 7: lastMsgId
    "\"LAST_MSG_SENDER_NM\" TEXT," + // 8: lastMsgSenderNm
    "\"LAST_MSG_TYPE\" INTEGER," + // 9: lastMsgType
    "\"LAST_MSG_CONTENT\" TEXT," + // 10: lastMsgContent
    "\"LAST_MSG_TIME\" INTEGER);"; // 11: lastMsgTime
  store.executeSql(sql_create_convtable);
  let sql_create_msgtable = "CREATE TABLE " + constraint + "\"tb_msg_content\" (" + //
    "\"_id\" INTEGER PRIMARY KEY AUTOINCREMENT ," + // 0: tab_Id
    "\"LOGIN_UID\" TEXT," + // 1: loginUId
    "\"CONV_ID\" INTEGER," + // 2: convId
    "\"CONV_TYPE\" INTEGER," + // 3: convType
    "\"SENDER_ID\" TEXT," + // 4: senderId
    "\"SENDER_NM\" TEXT," + // 5: senderNm
    "\"SENDER_TYPE\" INTEGER," + // 6: senderType
    "\"RECV_ID\" TEXT," + // 7: recvId
    "\"RECV_NM\" TEXT," + // 8: recvNm
    "\"RECV_TYPE\" INTEGER," + // 9: recvType
    "\"MSG_TYPE\" INTEGER," + // 10: msgType
    "\"CONTENT\" TEXT," + // 11: content
    "\"URL\" TEXT," + // 12: url
    "\"THUMBURL\" TEXT," + // 13: thumburl
    "\"PLAYTIME\" INTEGER," + // 14: playtime
    "\"TIME\" INTEGER);"
  store.executeSql(sql_create_msgtable);
}

function dropTable(store: relationalStore.RdbStore, ifExists:boolean) {
  let sql_drop_convtable = "DROP TABLE " + (ifExists ? "IF EXISTS " : "") + "\"tb_msg_conversation\"";
  store.executeSql(sql_drop_convtable);
  let sql_drop_msgtable = "DROP TABLE " + (ifExists ? "IF EXISTS " : "") + "\"tb_msg_content\"";
  store.executeSql(sql_drop_msgtable);
}

async function queryConvList(store: relationalStore.RdbStore, uid:string): Promise<MsgConversationBean[]> {
  let convlist:Array<MsgConversationBean> = [];
  let predicates = new relationalStore.RdbPredicates('tb_msg_conversation');
  predicates.equalTo('LOGIN_UID', uid);
  await store.query(predicates, ['_id', 'LOGIN_UID', 'CONV_ID', 'CONV_TYPE', 'CONV_NM',
    'MSG_CNT', 'MSG_UN_READ_CNT',
    'LAST_MSG_ID', 'LAST_MSG_SENDER_NM', 'LAST_MSG_TYPE', 'LAST_MSG_CONTENT', 'LAST_MSG_TIME'])
    .then((resultSet: relationalStore.ResultSet) => {
      while(resultSet.goToNextRow()) {
        const id = resultSet.getValue(resultSet.getColumnIndex('_id')) as number;
        const uid = resultSet.getValue(resultSet.getColumnIndex('LOGIN_UID')) as string;
        const convid = resultSet.getValue(resultSet.getColumnIndex('CONV_ID')) as number;
        const convtype = resultSet.getValue(resultSet.getColumnIndex('CONV_TYPE')) as number;
        const convnm = resultSet.getValue(resultSet.getColumnIndex('CONV_NM')) as string;
        const msgcnt = resultSet.getValue(resultSet.getColumnIndex('MSG_CNT')) as number;
        const msgunreadcnt = resultSet.getValue(resultSet.getColumnIndex('MSG_UN_READ_CNT')) as number;
        const lastmsgid = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_ID')) as number;
        const lastmsgsendnm = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_SENDER_NM')) as string;
        const lastmsgtype = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_TYPE')) as number;
        const lastmsgcont = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_CONTENT')) as string;
        const lastmsgtime = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_TIME')) as number;
        convlist.push(new MsgConversationBean(id, uid, convid, convtype, convnm, msgcnt, msgunreadcnt,
          lastmsgid, lastmsgsendnm, lastmsgtype, lastmsgcont, lastmsgtime));
      }
      resultSet.close();
    })
    .catch((err: BusinessError) => {
      hilog.error(0x0000, 'DB', `Query1 failed, code is ${err.code},message is ${err.message}`);
    })
  return convlist;
}

async function saveMsgContent(store: relationalStore.RdbStore, uid: string, msg: GWMsgBean) : Promise<MsgContentBean> {
  let msgBean: MsgContentBean = new MsgContentBean(-1, '', 0, 0, '', '', 0, '', '', 0, 0, '', '', '', 0, 0);
  msgBean.loginUid = uid;
  msgBean.senderId = msg.data.sendId;
  msgBean.senderNm = msg.data.sendName;
  msgBean.senderType = msg.data.sendUType;
  msgBean.recvId = msg.data.receiveId;
  msgBean.recvNm = msg.data.receiveName;
  msgBean.recvType = msg.data.receiveUType;
  msgBean.msgType = msg.data.msgType;
  let msgtype = msg.data.msgType;
  if (msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT) {
    msgBean.content = msg.data.content;
    msgBean.url = '';
    msgBean.thumburl = '';
  }
  else if (msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO
    || msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VOICE
    || msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_PHOTO) {
    msgBean.content = '';
    msgBean.url = msg.data.url;
    if (msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO) {
      msgBean.thumburl = msg.data.thumbUrl;
    }
    else {
      msgBean.thumburl = '';
    }
  }
  else {
    msgBean.content = msg.data.content;
    msgBean.url = '';
    msgBean.thumburl = '';
  }
  msgBean.time = msg.time;
  if (msg.data.receiveUType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER
    || msg.data.receiveUType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_DISPATCH) {
    if (uid === msg.data.sendId) {
      msgBean.convId = parseInt(msg.data.receiveId);
    }
    else {
      msgBean.convId = parseInt(msg.data.sendId);
    }
  }
  else {
    msgBean.convId = parseInt(msg.data.receiveId);
  }
  msgBean.convType = msg.data.receiveUType;
  msgBean.playtime = 0;
  const msgData: relationalStore.ValuesBucket = {
    'LOGIN_UID': msgBean.loginUid,
    'CONV_ID': msgBean.convId,
    'CONV_TYPE': msgBean.convType,
    'SENDER_ID': msgBean.senderId,
    'SENDER_NM': msgBean.senderNm,
    'SENDER_TYPE': msgBean.senderType,
    'RECV_ID': msgBean.recvId,
    'RECV_NM': msgBean.recvNm,
    'RECV_TYPE': msgBean.recvType,
    'MSG_TYPE': msgBean.msgType,
    'CONTENT': msgBean.content,
    'URL': msgBean.url,
    'THUMBURL': msgBean.thumburl,
    'PLAYTIME': msgBean.playtime,
    'TIME': msgBean.time
  };
  await store.insert('tb_msg_content', msgData)
    .then((value:number) => {
      msgBean.id = value;
    })
    .catch((err: BusinessError) => {
      hilog.error(0x0000, 'DB', `insert failed, code is ${err.code},message is ${err.message}`);
    })
  return msgBean;
}

function queryConversation(store: relationalStore.RdbStore, uid:string, convId:number, convType:number): (MsgConversationBean|null) {
  let conversation:MsgConversationBean|null = null;
  let predicates = new relationalStore.RdbPredicates('tb_msg_conversation');
  predicates.equalTo('LOGIN_UID', uid)
    .and()
    .equalTo('CONV_ID', convId)
    .and()
    .equalTo('CONV_TYPE', convType);
  let resultSet = store.querySync(predicates, ['_id', 'LOGIN_UID', 'CONV_ID', 'CONV_TYPE', 'CONV_NM',
    'MSG_CNT', 'MSG_UN_READ_CNT',
    'LAST_MSG_ID', 'LAST_MSG_SENDER_NM', 'LAST_MSG_TYPE', 'LAST_MSG_CONTENT', 'LAST_MSG_TIME']);
  if (resultSet.rowCount !== 0) {
    // this conv is exist
    resultSet.goToNextRow();
    const id = resultSet.getValue(resultSet.getColumnIndex('_id')) as number;
    const uid = resultSet.getValue(resultSet.getColumnIndex('LOGIN_UID')) as string;
    const convid = resultSet.getValue(resultSet.getColumnIndex('CONV_ID')) as number;
    const convtype = resultSet.getValue(resultSet.getColumnIndex('CONV_TYPE')) as number;
    const convnm = resultSet.getValue(resultSet.getColumnIndex('CONV_NM')) as string;
    const msgcnt = resultSet.getValue(resultSet.getColumnIndex('MSG_CNT')) as number;
    const msgunreadcnt = resultSet.getValue(resultSet.getColumnIndex('MSG_UN_READ_CNT')) as number;
    const lastmsgid = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_ID')) as number;
    const lastmsgsendnm = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_SENDER_NM')) as string;
    const lastmsgtype = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_TYPE')) as number;
    const lastmsgcont = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_CONTENT')) as string;
    const lastmsgtime = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_TIME')) as number;
    conversation = new MsgConversationBean(id, uid, convid, convtype, convnm, msgcnt, msgunreadcnt,
      lastmsgid, lastmsgsendnm, lastmsgtype, lastmsgcont, lastmsgtime);
  }
  resultSet.close();
  return conversation;
}

async function queryChatRecord(store: relationalStore.RdbStore, uid: string, convId:number, convType:number,
  pageNum: number, pageSize: number) : Promise<MsgContentBean[]> {
  let msgList: Array<MsgContentBean> = [];
  let predicates = new relationalStore.RdbPredicates('tb_msg_content');
  predicates.equalTo('LOGIN_UID', uid)
    .and()
    .equalTo('CONV_ID', convId)
    .and()
    .equalTo('CONV_TYPE', convType)
    .orderByDesc('TIME')
    .offsetAs(pageNum*pageSize)
    .limitAs(pageSize)
  await store.query(predicates,['_id', 'LOGIN_UID', 'CONV_ID', 'CONV_TYPE', 'SENDER_ID',
    'SENDER_NM', 'SENDER_TYPE', 'RECV_ID', 'RECV_NM', 'RECV_TYPE', 'MSG_TYPE', 'CONTENT',
    'URL', 'THUMBURL', 'PLAYTIME', 'TIME'])
    .then((resultSet :relationalStore.ResultSet) => {
      while(resultSet.goToNextRow()) {
        const id = resultSet.getValue(resultSet.getColumnIndex('_id')) as number;
        const uid = resultSet.getValue(resultSet.getColumnIndex('LOGIN_UID')) as string;
        const convid = resultSet.getValue(resultSet.getColumnIndex('CONV_ID')) as number;
        const convtype = resultSet.getValue(resultSet.getColumnIndex('CONV_TYPE')) as number;
        const senderid = resultSet.getValue(resultSet.getColumnIndex('SENDER_ID')) as string;
        const sendernm = resultSet.getValue(resultSet.getColumnIndex('SENDER_NM')) as string;
        const sendtype = resultSet.getValue(resultSet.getColumnIndex('SENDER_TYPE')) as number;
        const recverid = resultSet.getValue(resultSet.getColumnIndex('RECV_ID')) as string;
        const recvernm = resultSet.getValue(resultSet.getColumnIndex('RECV_NM')) as string;
        const recvtype = resultSet.getValue(resultSet.getColumnIndex('RECV_TYPE')) as number;
        const msgtype = resultSet.getValue(resultSet.getColumnIndex('MSG_TYPE')) as number;
        const content = resultSet.getValue(resultSet.getColumnIndex('CONTENT')) as string;
        const url = resultSet.getValue(resultSet.getColumnIndex('URL')) as string;
        const thumburl = resultSet.getValue(resultSet.getColumnIndex('THUMBURL')) as string;
        const playtime = resultSet.getValue(resultSet.getColumnIndex('PLAYTIME')) as number;
        const time = resultSet.getValue(resultSet.getColumnIndex('TIME')) as number;
        msgList.push(new MsgContentBean(id, uid, convid, convtype, senderid, sendernm, sendtype,
          recverid, recvernm, recvtype, msgtype, content, url, thumburl, playtime, time));
      }
      resultSet.close();
    })
    .catch((err: BusinessError) => {

    });
  msgList.reverse();
  return msgList;
}

function deleteConv(store: relationalStore.RdbStore, uid: string, convId:number, convType:number) {
  let predicates = new relationalStore.RdbPredicates('tb_msg_conversation');
  predicates.equalTo('LOGIN_UID', uid)
    .and()
    .equalTo('CONV_ID', convId)
    .and()
    .equalTo('CONV_TYPE', convType);
  store.delete(predicates)
    .then((rowId: number) => {

    })
    .catch((err: BusinessError) => {

    });
  //delete msg table
  predicates = new relationalStore.RdbPredicates('tb_msg_content');
  predicates.equalTo('LOGIN_UID', uid)
    .and()
    .equalTo('CONV_ID', convId)
    .and()
    .equalTo('CONV_TYPE', convType);
  store.delete(predicates)
    .then((row:number) => {

    })
    .catch((err: BusinessError) => {

    });
}

'user shared'
export class MsgDB {

  public store:relationalStore.RdbStore|undefined;

  private static INSTANCE:MsgDB = new MsgDB();

  public static getINSTANCE():MsgDB {
    return MsgDB.INSTANCE;
  }

  private constructor() {
  }

  public init(store: relationalStore.RdbStore) {
    this.store = store;
  }

  public dropTable(ifExists:boolean) {
    dropTable(this.store!, ifExists);
  }

  public createTable(ifNotExists:boolean) {
    createTable(this.store!, ifNotExists);
  }

  public async queryConvList(uid:string): Promise<MsgConversationBean[]> {
    return queryConvList(this.store!, uid);
  }

  public async saveMsgContent(uid: string, msg: GWMsgBean) : Promise<MsgContentBean> {
    return saveMsgContent(this.store!, uid, msg);
  }

  public async saveOrUpdateConv(msg: MsgContentBean, clearunread: boolean) : Promise<MsgConversationBean> {
    let conversation:MsgConversationBean|null = null;
    let convNm = '';
    if (msg.convType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER
      ||msg.convType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_DISPATCH) {
      if (msg.loginUid === msg.senderId) {
        convNm = msg.recvNm;
      }
      else {
        convNm = msg.senderNm;
      }
    }
    else {
      convNm = msg.recvNm;
    }
    conversation = queryConversation(this.store!, msg.loginUid, msg.convId, msg.convType);
    if (conversation === null) {
      conversation = new MsgConversationBean(-1, msg.loginUid, msg.convId, msg.convType, convNm, 1, 0,
        0, '', 0, '', 0);
      conversation.msgUnReadCnt = 0;
    }
    conversation.loginUid = msg.loginUid;
    conversation.convId = msg.convId;
    conversation.convType = msg.convType;
    conversation.convNm = convNm;
    conversation.lastMsgId = msg.id;
    conversation.lastMsgSenderNm = msg.senderNm;
    conversation.lastMsgType = msg.msgType;
    conversation.lastMsgTime = msg.time;
    conversation.lastMsgContent = msg.content;
    if (msg.loginUid === msg.senderId) {
      conversation.msgUnReadCnt = 0;
    }
    else {
      if (!clearunread) {
        let unread = conversation.msgUnReadCnt;
        conversation.msgUnReadCnt = unread+1;
      }
    }
    if (conversation.id === -1) {
      const convData: relationalStore.ValuesBucket = {
        'LOGIN_UID': conversation.loginUid,
        'CONV_ID': conversation.convId,
        'CONV_TYPE': conversation.convType,
        'CONV_NM': conversation.convNm,
        'MSG_CNT': conversation.msgCnt,
        'MSG_UN_READ_CNT': conversation.msgUnReadCnt,
        'LAST_MSG_ID': conversation.lastMsgId,
        'LAST_MSG_SENDER_NM': conversation.lastMsgSenderNm,
        'LAST_MSG_TYPE': conversation.lastMsgType,
        'LAST_MSG_CONTENT': conversation.lastMsgContent,
        'LAST_MSG_TIME': conversation.lastMsgTime
      };
      await this.store!.insert('tb_msg_conversation', convData,
        relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rowId: number) => {
        hilog.error(0x0000, 'DB', `insert failed, code is ${rowId}`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'DB', `insert failed, code is ${err.code},message is ${err.message}`);
      });
    }
    else {
      let predicates = new relationalStore.RdbPredicates('tb_msg_conversation');
      predicates.equalTo('_id', conversation.id);
      const convData: relationalStore.ValuesBucket = {
        'LOGIN_UID': conversation.loginUid,
        'CONV_ID': conversation.convId,
        'CONV_TYPE': conversation.convType,
        'CONV_NM': conversation.convNm,
        'MSG_CNT': conversation.msgCnt,
        'MSG_UN_READ_CNT': conversation.msgUnReadCnt,
        'LAST_MSG_ID': conversation.lastMsgId,
        'LAST_MSG_SENDER_NM': conversation.lastMsgSenderNm,
        'LAST_MSG_TYPE': conversation.lastMsgType,
        'LAST_MSG_CONTENT': conversation.lastMsgContent,
        'LAST_MSG_TIME': conversation.lastMsgTime
      };
      await this.store!.update(convData, predicates).then((rowId: number) => {
        hilog.error(0x0000, 'DB', `insert failed, code is ${rowId}`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'DB', `insert failed, code is ${err.code},message is ${err.message}`);
      })
    }
    return conversation;
  }

  public async updateConvRead(uid: string, convId:number, convType:number) {
    let conversation:MsgConversationBean|null = null;
    conversation = queryConversation(this.store!, uid, convId, convType);
    if (conversation != null) {
      conversation.msgUnReadCnt = 0;
      let predicates = new relationalStore.RdbPredicates('tb_msg_conversation');
      predicates.equalTo('_id', conversation.id)
      const convData: relationalStore.ValuesBucket = {
        'MSG_UN_READ_CNT': conversation.msgUnReadCnt,
      };
      await this.store!.update(convData, predicates)
        .then((rowId: number) => {

        })
        .catch((err: BusinessError) => {

        })
    }
  }

  public async queryChatRecord(uid: string, convId:number, convType:number,
    pageNum: number, pageSize: number) : Promise<MsgContentBean[]> {
    return queryChatRecord(this.store!, uid, convId, convType, pageNum, pageSize);
  }

  public deleteConv(uid: string, convId:number, convType:number) {
    deleteConv(this.store!, uid, convId, convType);
  }
}








@Concurrent
export async function saveMsgContentTask(ctx: common.UIAbilityContext, uid: string, msg: GWMsgBean) : Promise<MsgContentBean> {
  let msgBean: MsgContentBean = new MsgContentBean(-1, '', 0, 0, '', '', 0, '', '', 0, 0, '', '', '', 0, 0);
  msgBean.loginUid = uid;
  msgBean.senderId = msg.data.sendId;
  msgBean.senderNm = msg.data.sendName;
  msgBean.senderType = msg.data.sendUType;
  msgBean.recvId = msg.data.receiveId;
  msgBean.recvNm = msg.data.receiveName;
  msgBean.msgType = msg.data.msgType;
  let msgtype = msg.data.msgType;
  if (msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_TEXT) {
    msgBean.content = msg.data.content;
    msgBean.url = '';
    msgBean.thumburl = '';
  }
  else if (msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO
    || msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VOICE
    || msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_PHOTO) {
    msgBean.content = '';
    msgBean.url = msg.data.url;
    if (msgtype === GWType.GW_MSG_TYPE.GW_PTT_MSG_TYPE_VIDEO) {
      msgBean.thumburl = msg.data.thumbUrl;
    }
    else {
      msgBean.thumburl = '';
    }
  }
  else {
    msgBean.content = msg.data.content;
    msgBean.url = '';
    msgBean.thumburl = '';
  }
  msgBean.time = msg.time;
  if (msg.data.receiveUType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER
    || msg.data.receiveUType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_DISPATCH) {
    if (uid === msg.data.sendId) {
      msgBean.convId = parseInt(msg.data.receiveId);
    }
    else {
      msgBean.convId = parseInt(msg.data.sendId);
    }
  }
  else {
    msgBean.convId = parseInt(msg.data.receiveId);
  }
  msgBean.convType = msg.data.receiveUType;
  msgBean.playtime = 0;
  const msgData: relationalStore.ValuesBucket = {
    'LOGIN_UID': msgBean.loginUid,
    'CONV_ID': msgBean.convId,
    'CONV_TYPE': msgBean.convType,
    'SENDER_ID': msgBean.senderId,
    'SENDER_NM': msgBean.senderNm,
    'SENDER_TYPE': msgBean.senderType,
    'RECV_ID': msgBean.recvId,
    'RECV_NM': msgBean.recvNm,
    'RECV_TYPE': msgBean.recvType,
    'MSG_TYPE': msgBean.msgType,
    'CONTENT': msgBean.content,
    'URL': msgBean.url,
    'THUMBURL': msgBean.thumburl,
    'PLAYTIME': msgBean.playtime,
    'TIME': msgBean.time
  };
  // 默认数据库文件路径为 context.databaseDir + rdb + StoreConfig.name
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(ctx, STORE_CONFIG);
  await store.insert('tb_msg_content', msgData)
    .then((value:number) => {
      msgBean.id = value;
    })
    .catch((err: BusinessError) => {
      hilog.error(0x0000, 'DB', `insert failed, code is ${err.code},message is ${err.message}`);
    })
  return msgBean;
}

// @Concurrent
// export async function saveOrUpdateConvTask(ctx: common.UIAbilityContext, msg:MsgContentBean, clearunread: boolean) : Promise<MsgConversationBean> {
//   let conversation:MsgConversationBean|null = null;
//   let convNm = '';
//   if (msg.convType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_USER
//     ||msg.convType === GWType.GW_MSG_RECV_TYPE.GW_PTT_MSG_RECV_TYPE_DISPATCH) {
//     if (msg.loginUid === msg.senderId) {
//       convNm = msg.recvNm;
//     }
//     else {
//       convNm = msg.senderNm;
//     }
//   }
//   else {
//     convNm = msg.recvNm;
//   }
//   // 默认数据库文件路径为 context.databaseDir + rdb + StoreConfig.name
//   let store: relationalStore.RdbStore = await relationalStore.getRdbStore(ctx, STORE_CONFIG);
//   let predicates = new relationalStore.RdbPredicates('tb_msg_conversation');
//   predicates.equalTo('LOGIN_UID', msg.loginUid)
//     .and()
//     .equalTo('CONV_ID', msg.convId)
//     .and()
//     .equalTo('CONV_TYPE', msg.convType);
//   let resultSet = store.querySync(predicates, ['_id', 'LOGIN_UID', 'CONV_ID', 'CONV_TYPE', 'CONV_NM',
//     'MSG_CNT', 'MSG_UN_READ_CNT',
//     'LAST_MSG_ID', 'LAST_MSG_SENDER_NM', 'LAST_MSG_TYPE', 'LAST_MSG_CONTENT', 'LAST_MSG_TIME']);
//   if (resultSet.rowCount !== 0) {
//     // this conv is exist
//     resultSet.goToNextRow();
//     const id = resultSet.getValue(resultSet.getColumnIndex('_id')) as number;
//     const uid = resultSet.getValue(resultSet.getColumnIndex('LOGIN_UID')) as string;
//     const convid = resultSet.getValue(resultSet.getColumnIndex('CONV_ID')) as number;
//     const convtype = resultSet.getValue(resultSet.getColumnIndex('CONV_TYPE')) as number;
//     const convnm = resultSet.getValue(resultSet.getColumnIndex('CONV_NM')) as string;
//     const msgcnt = resultSet.getValue(resultSet.getColumnIndex('MSG_CNT')) as number;
//     const msgunreadcnt = resultSet.getValue(resultSet.getColumnIndex('MSG_UN_READ_CNT')) as number;
//     const lastmsgid = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_ID')) as number;
//     const lastmsgsendnm = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_SENDER_NM')) as string;
//     const lastmsgtype = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_TYPE')) as number;
//     const lastmsgcont = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_CONTENT')) as string;
//     const lastmsgtime = resultSet.getValue(resultSet.getColumnIndex('LAST_MSG_TIME')) as number;
//     conversation = new MsgConversationBean(id, uid, convid, convtype, convnm, msgcnt, msgunreadcnt,
//       lastmsgid, lastmsgsendnm, lastmsgtype, lastmsgcont, lastmsgtime);
//   }
//   resultSet.close();
//   if (conversation === null) {
//     conversation = new MsgConversationBean(-1, msg.loginUid, msg.convId, msg.convType, convNm, 1, 0,
//       0, '', 0, '', 0);
//     conversation.msgUnReadCnt = 0;
//   }
//   conversation.loginUid = msg.loginUid;
//   conversation.convId = msg.convId;
//   conversation.convType = msg.convType;
//   conversation.convNm = convNm;
//   conversation.lastMsgId = msg.id;
//   conversation.lastMsgSenderNm = msg.senderNm;
//   conversation.lastMsgType = msg.msgType;
//   conversation.lastMsgTime = msg.time;
//   conversation.lastMsgContent = msg.content;
//   if (msg.loginUid === msg.senderId) {
//     conversation.msgUnReadCnt = 0;
//   }
//   else {
//     if (!clearunread) {
//       let unread = conversation.msgUnReadCnt;
//       conversation.msgUnReadCnt = unread+1;
//     }
//   }
//   if (conversation.id === -1) {
//     const convData: relationalStore.ValuesBucket = {
//       'LOGIN_UID': conversation.loginUid,
//       'CONV_ID': conversation.convId,
//       'CONV_TYPE': conversation.convType,
//       'CONV_NM': conversation.convNm,
//       'MSG_CNT': conversation.msgCnt,
//       'MSG_UN_READ_CNT': conversation.msgUnReadCnt,
//       'LAST_MSG_ID': conversation.lastMsgId,
//       'LAST_MSG_SENDER_NM': conversation.lastMsgSenderNm,
//       'LAST_MSG_TYPE': conversation.lastMsgType,
//       'LAST_MSG_CONTENT': conversation.lastMsgContent,
//       'LAST_MSG_TIME': conversation.lastMsgTime
//     };
//     await store.insert('tb_msg_conversation', convData,
//       relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rowId: number) => {
//       hilog.error(0x0000, 'DB', `insert failed, code is ${rowId}`);
//     }).catch((err: BusinessError) => {
//       hilog.error(0x0000, 'DB', `insert failed, code is ${err.code},message is ${err.message}`);
//     });
//   }
//   else {
//     let predicates = new relationalStore.RdbPredicates('tb_msg_conversation');
//     predicates.equalTo('_id', conversation.id);
//     const convData: relationalStore.ValuesBucket = {
//       'LOGIN_UID': conversation.loginUid,
//       'CONV_ID': conversation.convId,
//       'CONV_TYPE': conversation.convType,
//       'CONV_NM': conversation.convNm,
//       'MSG_CNT': conversation.msgCnt,
//       'MSG_UN_READ_CNT': conversation.msgUnReadCnt,
//       'LAST_MSG_ID': conversation.lastMsgId,
//       'LAST_MSG_SENDER_NM': conversation.lastMsgSenderNm,
//       'LAST_MSG_TYPE': conversation.lastMsgType,
//       'LAST_MSG_CONTENT': conversation.lastMsgContent,
//       'LAST_MSG_TIME': conversation.lastMsgTime
//     };
//     await store.update(convData, predicates).then((rowId: number) => {
//       hilog.error(0x0000, 'DB', `insert failed, code is ${rowId}`);
//     }).catch((err: BusinessError) => {
//       hilog.error(0x0000, 'DB', `insert failed, code is ${err.code},message is ${err.message}`);
//     })
//   }
//   return conversation;
// }
