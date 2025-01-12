import { relationalStore } from '@kit.ArkData'; // 导入模块
import { common } from '@kit.AbilityKit';
import { MsgDB } from './MsgDB';

const DB_VERSION:number = 1;

export const STORE_CONFIG :relationalStore.StoreConfig= {
  name: 'gwsd_ptt.db', // 数据库文件名
  securityLevel: relationalStore.SecurityLevel.S3, // 数据库安全级别
  encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
  customDir: 'customDir/subCustomDir', // 可选参数，数据库自定义路径。数据库将在如下的目录结构中被创建：context.databaseDir + '/rdb/' + customDir，其中context.databaseDir是应用沙箱对应的路径，'/rdb/'表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。
  isReadOnly: false // 可选参数，指定数据库是否以只读方式打开。该参数默认为false，表示数据库可读可写。该参数为true时，只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。
};

'user shared'
export class DBManager {

  public rdbObj:relationalStore.RdbStore|undefined;

  private static INSTANCE:DBManager = new DBManager();

  public static getINSTANCE():DBManager {
    return DBManager.INSTANCE;
  }

  private constructor() {
  }

  public initDBManager(ctx: common.UIAbilityContext) {
    relationalStore.getRdbStore(ctx, STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info('Succeeded in getting RdbStore.');

      MsgDB.getINSTANCE().init(store);
      // 当数据库创建时，数据库默认版本为0
      if (store.version === 0) {
        MsgDB.getINSTANCE().createTable(false);
        // 设置数据库的版本，入参为大于0的整数
        store.version = DB_VERSION;
      }
      this.rdbObj = store;
    })
  }

}

//let rdbObject:relationalStore.RdbStore;
// export function getRDB(): relationalStore.RdbStore {
//   return rdbObject;
// }

// export function initDBManager(ctx: common.UIAbilityContext) {
//   relationalStore.getRdbStore(ctx, STORE_CONFIG, (err, store) => {
//     if (err) {
//       console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
//       return;
//     }
//     console.info('Succeeded in getting RdbStore.');
//
//     // 当数据库创建时，数据库默认版本为0
//     if (store.version === 0) {
//       MsgDB.createTable(store, false);
//       // 设置数据库的版本，入参为大于0的整数
//       store.version = DB_VERSION;
//     }
//     rdbObject = store;
//   });
// }
