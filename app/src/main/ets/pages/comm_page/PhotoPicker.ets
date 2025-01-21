import { fileIo } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[AudioDemo]';

@Entry
@Component
struct PhotoPicker {
  private context = getContext(this) as common.UIAbilityContext;
  private filesDir: string = this.context.filesDir;
  @State recordFlag: boolean = false;
  @State continueFlag: boolean = true;
  @State fileNames: Array<[string, number]> = [];
  @State totalTime: number = 0;
  @State currentIndex: number = -1;
  @State format: string = 'mm:ss.SS';
  @State curFileUri: string = '';
  @State flag: boolean = false;
  @State isPlay: boolean = false;
  @State isOpacity: boolean = false;
  @State currentTime: number = 0;
  @State durationTime: number = 0;
  @State durationStringTime: string = '00:00';
  @State currentStringTime: string = '00:00';
  private curFile: fileIo.File | undefined = undefined;
  private avRecorder: media.AVRecorder | undefined = undefined;
  private avPlayer: media.AVPlayer | undefined = undefined;
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: 100000, // 音频比特率
    audioChannels: 1, // 音频声道数
    audioCodec: media.CodecMimeType.AUDIO_MP3, // 音频编码格式，当前只支持aac
    audioSampleRate: 16000, // 音频采样率
    fileFormat: media.ContainerFormatType.CFT_MP3, // 封装格式，当前只支持m4a
  };
  private avConfig: media.AVRecorderConfig = {
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，这里设置为麦克风
    profile: this.avProfile,
    url: '', // 参考应用文件访问与管理开发示例新建并读写一个文件
  };
  textTimerController: TextTimerController = new TextTimerController()

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text('音频录制')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Column({space: 5}) {
        Text(`${this.recordFlag ? '正在录音...' : '未开始录音'}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        TextTimer({ isCountDown: false, count: 30000, controller: this.textTimerController })
          .format(this.format)
          .fontColor(Color.Black)
          .fontSize(50)
          .onTimer((utc: number, elapsedTime: number) => {
            this.totalTime = elapsedTime / 1000;
            console.info(TAG, 'textTimer notCountDown utc is：' + utc + ', elapsedTime: ' + elapsedTime)
          })

        if (this.isPlay) {
          Text(`正在播放：${this.fileNames[this.currentIndex][0]}`)
            .fontSize(20)
            .fontWeight(FontWeight.Normal)
          this.PlayControl()
        }
      }

      Column({ space: 5 }) {
        Text('文件列表(点击播放)')
          .fontSize(20)
          .onClick(() => {
            //this.getFileList()
          })

        Scroll() {
          List({ space: 5 }) {
            ForEach(this.fileNames, (item: [string, number], index: number) => {
              ListItem() {
                Text(`${item[0]} ${item[1]}s`) {
                  Span(`${item[0]} `)
                  Span(`${item[1]}s`).fontColor(Color.Blue)
                }
                .backgroundColor('#f1f3f5')
                .padding({ left: 20, right: 20, top: 8, bottom: 8 })
                .width('100%')
                .borderRadius(15)
                .borderWidth(1)
                .borderColor(this.currentIndex == index ? Color.Blue : Color.Gray)
              }
              .onClick(() => {
                this.isPlay = true;
                this.currentIndex = index;
                let file = fileIo.openSync(`${this.filesDir}/${item[0]}`)
                this.curFileUri = `fd://${file.fd}`;
                this.startPlayingProcess();
              })
            })
          }
        }
        .scrollBar(BarState.Off)
      }
      .width('95%')
      .height('50%')
      .padding(20)
      .borderRadius(20)

      Text('按住说话')
        .fontSize(20)
        .fontWeight(FontWeight.Normal)
        .width(300)
        .height(40)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Orange)
        .border({ radius: 20 })// 单指长按文本触发该手势事件
        .gesture(
          LongPressGesture({ repeat: false })
            .onAction(async (event?: GestureEvent) => {
              console.info(TAG, `LongPressGesture onAction.${JSON.stringify(event)}`)
              // 长按录音
              await this.startRecordingProcess();
            })// 长按动作一结束触发
            .onActionEnd(async () => {
              console.info(TAG, `LongPressGesture onActionEnd.`)
              await this.stopRecordingProcess();
            })
        )
    }
    .margin({ top: 10 })
    .width('100%')
    .height('95%')
  }

  @Builder
  PlayControl() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Image(this.isPlay ? $r('app.media.ic_record_play') : $r('app.media.ic_record_play'))
        .width('24vp')
        .height('24vp')
        .onClick(() => {
          this.iconOnclick();
        });
      Text(this.currentStringTime)
        .fontSize('14vp')
        .fontColor(Color.White)
        .margin({ left: '4vp' })
      Slider({
        value: this.currentTime,
        step: 1,
        min: 0,
        max: this.durationTime,
        style: SliderStyle.OutSet
      })
        .blockColor(Color.White)
        .width('60%')
        .trackColor(Color.Gray)
        .selectedColor(Color.White)
        .showSteps(false)
        .showTips(false)
        .trackThickness(this.isOpacity ? 2 : 4)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.sliderOnchange(value, mode);
        });
      Text(this.durationStringTime)
        .fontSize('14vp')
        .fontColor(Color.White)
        .margin({ left: '4vp', right: '4vp' })
    }
    .zIndex(2)
    .padding({ right: '4vp' })
    .opacity(this.isOpacity ? 0.7 : 1)
    .width('100%')
    .backgroundBlurStyle(BlurStyle.Thin, { colorMode: ThemeColorMode.DARK })
  }

  iconOnclick() {
    if (this.isPlay === true) {
      this.avPlayer && this.avPlayer.pause();
      this.isPlay = false;
      this.isOpacity = false;
      return;
    }
    if (this.flag === true) {
      this.avPlayer && this.avPlayer.play();
      this.isPlay = true;
      this.isOpacity = true;
    } else {
      // The scheduled task determines whether the video loading is complete.
      let intervalFlag = setInterval(() => {
        if (this.flag === true) {
          this.avPlayer && this.avPlayer.play();
          this.isPlay = true;
          this.isOpacity = true;
          clearInterval(intervalFlag);
        }
      }, 100);
    }
  }

  sliderOnchange(value: number, mode: SliderChangeMode) {
    console.info(`AVPlayerDemo sliderOnchange. value is ${value}`);
    if (!this.avPlayer) {
      return;
    }
    this.currentTime = value
    if (mode === SliderChangeMode.Begin || mode === SliderChangeMode.Moving) {
      this.isOpacity = false;
    }
    if (mode === SliderChangeMode.End && this.avPlayer) {
      let seekTime: number = value * this.avPlayer.duration / this.durationTime;
      this.currentStringTime = this.secondToTime(Math.floor(seekTime / 1000));
      console.info(`AVPlayerDemo sliderOnchange. time is ${seekTime}, currentTime is ${this.currentTime}`);
      this.avPlayer.seek(seekTime, media.SeekMode.SEEK_PREV_SYNC);
      this.isOpacity = true;
    }
  }

  /**
   * Seconds converted to HH:mm:ss.
   *
   * @param seconds Maximum video duration (seconds).
   * @return Time after conversion.
   */
  secondToTime(seconds: number): string {
    let hourUnit = 60 * 60;
    let hour: number = Math.floor(seconds / hourUnit);
    let minute: number = Math.floor((seconds - hour * hourUnit) / 60);
    let second: number = seconds - hour * hourUnit - minute * 60;
    let hourStr: string = hour < 10 ? `0${hour.toString()}` : `${hour.toString()}`
    let minuteStr: string = minute < 10 ? `0${minute.toString()}` : `${minute.toString()}`
    let secondStr: string = second < 10 ? `0${second.toString()}` : `${second.toString()}`
    if (hour > 0) {
      return `${hourStr}:${minuteStr}:${secondStr}`;
    }
    if (minute > 0) {
      return `${minuteStr}:${secondStr}`;
    } else {
      return `00:${secondStr}`;
    }
  }

  aboutToAppear(): void {
    let permissions: Array<Permissions> = ['ohos.permission.MICROPHONE', 'ohos.permission.READ_MEDIA', 'ohos.permission.WRITE_MEDIA'];
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    atManager.requestPermissionsFromUser(this.context, permissions).then((data: PermissionRequestResult) => {
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] != 0) {
          // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
          return;
        }
      }
      console.info(`${TAG} Success to request permissions from user. authResults is ${grantStatus}.`);
    }).catch((err: BusinessError) => {
      console.error(`${TAG} Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    })
  }

  // 开始录制对应的流程
  async startRecordingProcess() {
    try {
      if (this.avRecorder == undefined) {
        // 1.创建录制实例
        this.avRecorder = await media.createAVRecorder();
      }

      this.setAudioRecorderCallback();
      // 2.获取录制文件fd赋予avConfig里的url；参考FilePicker文档
      this.curFile = fileIo.openSync(this.filesDir + '/Audio_' + new Date().getTime() + '.mp3', fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      this.avConfig.url = 'fd://' + this.curFile.fd;
      // 3.配置录制参数完成准备工作
      await this.avRecorder.prepare(this.avConfig);
      // 4.开始录制
      this.textTimerController.start()
      await this.avRecorder.start();
      this.recordFlag = true;
    } catch (err) {
      console.log(TAG, 'startRecordingProcess' + JSON.stringify(err))
    }
  }

  // 停止录制对应的流程
  async stopRecordingProcess() {
    if (this.avRecorder != undefined) {
      // 1. 停止录制
      if (this.avRecorder.state === 'started'
        || this.avRecorder.state === 'paused') { // 仅在started或者paused状态下调用stop为合理状态切换
        await this.avRecorder.stop();
      }
      // 2.重置
      this.recordFlag = false;
      await this.avRecorder.reset();
      this.textTimerController.reset();
      // 3.释放录制实例
      await this.avRecorder.release();
      this.fileNames.push([this.curFile?.name ? this.curFile?.name : '', this.totalTime])
      // 4.关闭录制文件fd
      fileIo.closeSync(this.curFile)
      this.avRecorder = undefined;
    }
  }

  // 注册audioRecorder回调函数
  setAudioRecorderCallback() {
    if (this.avRecorder != undefined) {
      // 状态机变化回调函数
      this.avRecorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
        console.log(TAG, `AudioRecorder current state is ${state}`);
      })
      // 错误上报回调函数
      this.avRecorder.on('error', (err: BusinessError) => {
        console.error(TAG, `AudioRecorder failed, code is ${err.code}, message is ${err.message}`);
      })
    }
  }

  async startPlayingProcess() {
    if (this.avPlayer == undefined) {
      await this.createAVPlayer();
    }
    if (!this.avPlayer) {
      console.error('AVPlayerDemo play failed. avPlayer is undefined.')
      return;
    }
    if (this.avPlayer.state === 'playing' && this.curFileUri === this.avPlayer.url) {
      console.info('AVPlayerDemo play failed. avPlayer is playing.')
      return;
    }
    if (this.avPlayer.state === 'playing' && this.curFileUri !== this.avPlayer.url) {
      await this.avPlayer.stop();
    }
    this.reset();
    await this.avPlayer.reset();
  }

  async createAVPlayer() {
    await media.createAVPlayer().then((video: media.AVPlayer) => {
      if (video != null) {
        this.avPlayer = video;
        this.setAVPlayerCallback(this.avPlayer);
        if (this.avPlayer && this.curFileUri) {
          this.avPlayer.url = this.curFileUri;
        }
        this.avPlayer.play();
        console.info('AVPlayerDemo createAVPlayer success');
      } else {
        console.error('AVPlayerDemo createAVPlayer fail');
      }
    }).catch((error: BusinessError) => {
      console.error(`AVPlayerDemo AVPlayer catchCallback, error message:${error.message}`);
    });
  }

  // 注册avplayer回调函数
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('timeUpdate', (time: number) => {
      console.info(`AVPlayerDemo AVPlayer timeUpdate. time is ${time}`);
      this.currentTime = Math.floor(time * this.durationTime / avPlayer.duration);
      console.info(`AVPlayerDemo this.currentTime. time is ${this.currentTime}`);
      this.currentStringTime = this.secondToTime(Math.floor(time / 1000));
    })

    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      console.info(`AVPlayerDemo AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      console.error(`AVPlayerDemo Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      avPlayer.reset(); // 调用reset重置资源，触发idle状态
    })

    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          console.info('AVPlayerDemo AVPlayer state idle called.');
          if (avPlayer && this.curFileUri) {
            avPlayer.url = this.curFileUri;
          }
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          console.info('AVPlayerDemo AVPlayer state initialized called.');
          this.reset();
          avPlayer.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          console.info('AVPlayerDemo AVPlayer state prepared called.');
          this.flag = true;
          this.durationTime = Math.floor(avPlayer.duration / 1000);
          this.durationStringTime = this.secondToTime(this.durationTime);
          avPlayer.play();
          break;
        case 'playing': // play成功调用后触发该状态机上报
          this.isPlay = true;
          console.info('AVPlayerDemo AVPlayer state playing called.');
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          console.info('AVPlayerDemo AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          avPlayer.stop();
          this.currentIndex = -1;
          this.isPlay = false;
          this.currentTime = 0
          this.currentStringTime = '00:00'
          console.info('AVPlayerDemo AVPlayer state completed called.');
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          this.isPlay = false;
          console.info('AVPlayerDemo AVPlayer state stopped called.');
          break;
        case 'released':
          console.info('AVPlayerDemo AVPlayer state released called.');
          break;
        default:
          console.info('AVPlayerDemo AVPlayer state unknown called.');
          break;
      }
    })
  }

  reset() {
    this.isPlay = false;
    this.currentTime = 0;
    this.durationTime = 0;
    this.durationStringTime = '00:00';
    this.currentStringTime = '00:00';
    this.flag = false;
  }
}