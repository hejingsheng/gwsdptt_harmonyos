import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { router, window } from '@kit.ArkUI';

import { GWSDKManager } from '../service/GWSDKManager';
import { DBManager } from '../db/DBManager';
import { NotificationService } from '../service/NotificationService';
import { ChatParam } from '../service/ChatModel';

export default class AppAbility extends UIAbility {

  static TAG:string = 'GWAPP';

  private isForeground = true;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onCreate');
    GWSDKManager.getInstance().setContext(this.context);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onNewWant');
    let param: Record<string, Object>|undefined = want.parameters;
    if (param !== undefined) {
      let type = param['type'] as string;
      if (type === 'Msg') {
        // goto chat
        let chatparam = new ChatParam(param['convId'] as number, param['convType'] as number, param['convNm'] as string)
        router.pushUrl({
          url: 'pages/Chat',
          params: chatparam
        });
      }
      else if (type === 'VoiceCall') {

      }
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onWindowStageCreate');
    DBManager.getINSTANCE().initDBManager(this.context);
    NotificationService.getInstance().init(this.context);
    windowStage.loadContent('pages/Launcher', (err) => {
      if (err.code) {
        hilog.error(0x0000, AppAbility.TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, AppAbility.TAG, 'Succeeded in loading the content.');
    });
    //AppStorage.setAndLink('windowStage', windowStage)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onForeground');
    this.isForeground = true;
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onBackground');
    this.isForeground = false;
  }
}
