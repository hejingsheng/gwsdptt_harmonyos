import { media } from '@kit.MediaKit';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';

class AudioRecorder {
  private avRecorder: media.AVRecorder | undefined = undefined;
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: 128000, // 音频比特率
    audioChannels: 2, // 音频声道数
    audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前支持ACC，MP3，G711MU
    audioSampleRate: 16000, // 音频采样率
    fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前支持MP4，M4A，MP3，WAV
  };
  private avConfig: media.AVRecorderConfig = {
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，这里设置为麦克风
    profile: this.avProfile,
    url: 'fd://35', // 参考应用文件访问与管理开发示例新建并读写一个文件
  };
  private uriPath: string = '';
  private filePath: string = '';
  private audioFile: fs.File|undefined;

  // 创建文件以及设置avConfig.url
  async createAndSetFd(): Promise<void> {
    const context: Context = getContext(this);
    const filename = systemDateTime.getTime(false);
    const path: string = context.filesDir + '/' + filename + '.mp3'; // 文件沙箱路径，文件后缀名应与封装格式对应
    this.audioFile = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    this.avConfig.url = 'fd://' + this.audioFile.fd; // 更新url
    this.filePath = path;
  }

  // 注册audioRecorder回调函数
  setAudioRecorderCallback() {
    if (this.avRecorder != undefined) {
      // 状态机变化回调函数
      this.avRecorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
        console.log(`AudioRecorder current state is ${state}`);
      })
      // 错误上报回调函数
      this.avRecorder.on('error', (err: BusinessError) => {
        console.error(`AudioRecorder failed, code is ${err.code}, message is ${err.message}`);
      })
    }
  }

  // 开始录制对应的流程
  async startRecordingProcess() {
    if (this.avRecorder != undefined) {
      await this.avRecorder.release();
      this.avRecorder = undefined;
    }
    // 1.创建录制实例
    this.avRecorder = await media.createAVRecorder();
    this.setAudioRecorderCallback();
    // 2.获取录制文件fd赋予avConfig里的url；参考FilePicker文档

    // 3.配置录制参数完成准备工作
    await this.avRecorder.prepare(this.avConfig);
    // 4.开始录制
    await this.avRecorder.start();
  }

  // 暂停录制对应的流程
  async pauseRecordingProcess() {
    if (this.avRecorder != undefined && this.avRecorder.state === 'started') { // 仅在started状态下调用pause为合理状态切换
      await this.avRecorder.pause();
    }
  }

  // 恢复录制对应的流程
  async resumeRecordingProcess() {
    if (this.avRecorder != undefined && this.avRecorder.state === 'paused') { // 仅在paused状态下调用resume为合理状态切换
      await this.avRecorder.resume();
    }
  }

  // 停止录制对应的流程
  async stopRecordingProcess() : Promise<string> {
    if (this.avRecorder != undefined) {
      // 1. 停止录制
      if (this.avRecorder.state === 'started'
        || this.avRecorder.state === 'paused') { // 仅在started或者paused状态下调用stop为合理状态切换
        await this.avRecorder.stop();
      }
      // 2.重置
      await this.avRecorder.reset();
      // 3.释放录制实例
      await this.avRecorder.release();
      this.avRecorder = undefined;
      // 4.关闭录制文件fd
      fs.closeSync(this.audioFile);
      return this.filePath;
    }
    return '';
  }

  // // 一个完整的【开始录制-暂停录制-恢复录制-停止录制】示例
  // async audioRecorderDemo() {
  //   await this.startRecordingProcess(); // 开始录制
  //   // 用户此处可以自行设置录制时长，例如通过设置休眠阻止代码执行
  //   await this.pauseRecordingProcess(); //暂停录制
  //   await this.resumeRecordingProcess(); // 恢复录制
  //   await this.stopRecordingProcess(); // 停止录制
  // }
}

export default new AudioRecorder()