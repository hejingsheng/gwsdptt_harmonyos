// // TaskSendDataUsage.ets
// import { taskpool } from '@kit.ArkTS';
// import { hilog } from '@kit.PerformanceAnalysisKit';
//
// // IconItemSource.ets
// class IconItemSource {
//   image: string = '';
//   text: string = '';
//
//   constructor(image: string, text: string) {
//     this.image = image;
//     this.text = text;
//   }
// }
//
// // TaskSendDataUsage.ets
// function notice(data: number): void {
//   hilog.info(0x0000, 'Taskpool', '子线程任务已执行完，共加载图片: '+data);
// }
//
//
// // 通过Task的sendData方法，即时通知宿主线程信息
// @Concurrent
// export function loadPictureSendData(count: number): IconItemSource[] {
//   let iconItemSourceList: IconItemSource[] = [];
//   // 遍历添加6*count个IconItem的数据
//   for (let index = 0; index < count; index++) {
//     const numStart: number = index * 6;
//     // 此处循环使用6张图片资源
//     iconItemSourceList.push(new IconItemSource('1', '1'));
//     iconItemSourceList.push(new IconItemSource('2', '2'));
//     iconItemSourceList.push(new IconItemSource('3', '3'));
//     iconItemSourceList.push(new IconItemSource('4', '4'));
//     iconItemSourceList.push(new IconItemSource('5', '5'));
//     iconItemSourceList.push(new IconItemSource('6', '6'));
//     taskpool.Task.sendData(iconItemSourceList.length);
//   }
//   return iconItemSourceList;
// }
//
//
// @Entry
// @Component
// struct Index {
//   @State message: string = 'Hello World';
//
//   build() {
//     Row() {
//       Column() {
//         Text(this.message)
//           .fontSize(50)
//           .fontWeight(FontWeight.Bold)
//           .onClick(() => {
//             hilog.info(0x0000, 'Taskpool', 'start taskpool');
//             let iconItemSourceList: IconItemSource[];
//             let lodePictureTask: taskpool.Task = new taskpool.Task(loadPictureSendData, 30);
//             // 设置notice方法接收Task发送的消息
//             lodePictureTask.onReceiveData(notice);
//             taskpool.execute(lodePictureTask).then((res: object) => {
//               iconItemSourceList = res as IconItemSource[];
//               hilog.info(0x0000, 'Taskpool', 'start taskpool exec end');
//             })
//           })
//       }
//       .width('100%')
//     }
//     .height('100%')
//   }
// }
