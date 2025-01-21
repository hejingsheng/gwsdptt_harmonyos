import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';

export class AudioPlayer {

  private static INSTANCE: AudioPlayer = new AudioPlayer();
  public static getInstance() : AudioPlayer {
    return AudioPlayer.INSTANCE;
  }

  private avPlayer: media.AVPlayer|undefined;
  private onPlayState?: (state:number) => void;

  // 注册avplayer回调函数
  private setAVPlayerCallback() {
    // seek操作结果回调函数
    this.avPlayer?.on('seekDone', (seekDoneTime: number) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    this.avPlayer?.on('error', (err: BusinessError) => {
      console.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer?.reset(); // 调用reset重置资源，触发idle状态
    });
    // 状态机变化回调函数
    this.avPlayer?.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          console.info('AVPlayer state idle called.');
          //this.avPlayer?.release(); // 调用release接口销毁实例对象
          if (this.onPlayState) {
            this.onPlayState(1);
          }
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          console.info('AVPlayer state initialized called.');
          this.avPlayer!.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags: 0
          };
          this.avPlayer?.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          console.info('AVPlayer state prepared called.');
          this.avPlayer?.play(); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          console.info('AVPlayer state playing called.');
          if (this.onPlayState) {
            this.onPlayState(0);
          }
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          console.info('AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          console.info('AVPlayer state completed called.');
          this.avPlayer?.stop(); //调用播放结束接口
          console.info('AVPlayer state completed1 called.');
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          console.info('AVPlayer state stopped called.');
          this.avPlayer?.reset(); // 调用reset接口初始化avplayer状态
          break;
        case 'released':
          console.info('AVPlayer state released called.');
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    });
  }

  // 以下demo为通过url设置网络地址来实现播放直播码流的demo
  async avPlayerLive(url: string, onPlayState?: (state:number) => void) {
    // 创建avPlayer实例对象
    if (this.avPlayer === undefined) {
      this.avPlayer = await media.createAVPlayer();
      this.setAVPlayerCallback();
    }
    this.avPlayer.url = url;
    this.onPlayState = onPlayState;
  }

  async avPlayerStop() {
    this.avPlayer?.stop();
    console.log('AVPlayer state call stop')
  }
}
