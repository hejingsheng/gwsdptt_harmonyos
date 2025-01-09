import { relationalStore } from '@kit.ArkData'; // 导入模块
import { GWType, MsgContent } from 'gwsdptt_sdk';
import { MsgContentBean } from './MsgContentBean';
import { MsgConversationBean } from './MsgConversationBean';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export function createTable(store: relationalStore.RdbStore, ifNotExists:boolean) {
  let constraint:string = ifNotExists? "IF NOT EXISTS ": "";
  let sql_create_table = "CREATE TABLE " + constraint + "\"tb_msg_conversation\" (" + //
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
  store.executeSql(sql_create_table);
}

export function dropTable(store: relationalStore.RdbStore, ifExists:boolean) {
  let sql_drop_table = "DROP TABLE " + (ifExists ? "IF EXISTS " : "") + "\"tb_msg_conversation\"";
  store.executeSql(sql_drop_table);
}

export async function queryConvList(store: relationalStore.RdbStore, uid:string): Promise<MsgConversationBean[]> {
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

export async function saveOrUpdateConv(store: relationalStore.RdbStore, msg:MsgContentBean, clearunread: boolean) {
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
  conversation = queryConversation(store, msg.loginUid, msg.convId, msg.convType);
  if (conversation === null) {
    conversation = new MsgConversationBean(0, msg.loginUid, msg.convId, msg.convType, convNm, 1, 0,
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
  const convData: relationalStore.ValuesBucket = {
    '_id': conversation.id,
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
  store.insert('tb_msg_conversation', convData,
    relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rowId: number) => {
  }).catch((err: BusinessError) => {
  })
}

export function updateConvRead(store: relationalStore.RdbStore, uid: string, convId:number, convType:number) {
  let conversation:MsgConversationBean|null = null;
  conversation = queryConversation(store, uid, convId, convType);
  if (conversation != null) {
    conversation.msgUnReadCnt = 0;
    let predicates = new relationalStore.RdbPredicates('tb_msg_conversation');
    predicates.equalTo('_id', conversation.id)
    const convData: relationalStore.ValuesBucket = {
      'MSG_UN_READ_CNT': conversation.msgUnReadCnt,
    };
    store.update(convData, predicates)
      .then((rowId: number) => {

      })
      .catch((err: BusinessError) => {

      })
  }
}

export function deleteConv(store: relationalStore.RdbStore, uid: string, convId:number, convType:number) {
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
}

