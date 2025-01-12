import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

import { GWSDKManager } from '../service/GWSDKManager';
import { DBManager } from '../db/DBManager';

export default class AppAbility extends UIAbility {

  static TAG:string = 'GWAPP';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onCreate');
    GWSDKManager.getInstance().setContext(this.context);
  }

  onDestroy(): void {
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onWindowStageCreate');
    DBManager.getINSTANCE().initDBManager(this.context);
    windowStage.loadContent('pages/Launcher', (err) => {
      if (err.code) {
        hilog.error(0x0000, AppAbility.TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, AppAbility.TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, AppAbility.TAG, '%{public}s', 'Ability onBackground');
  }
}
