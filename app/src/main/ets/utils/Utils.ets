import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';

export function numberToTime(value: number) {
  let min = Math.floor(value/60);
  let sec = value%60;
  let minstr:string = '';
  let secstr:string = '';
  if (min < 10) {
    minstr = '0'+min;
  } else {
    minstr = ''+min;
  }
  if (sec < 10) {
    secstr = '0'+sec;
  } else {
    secstr = ''+sec;
  }
  return minstr+':'+secstr;
}

export function copyFile(uri: string, context: common.UIAbilityContext) : string {
  if (uri === undefined || uri === '') {
    return '';
  }
  let srcfile = fs.openSync(uri,fs.OpenMode.READ_ONLY);
  let filename = srcfile.name;
  let fileTemp = fs.openSync(context.filesDir+'/'+filename,fs.OpenMode.READ_WRITE|fs.OpenMode.CREATE);
  let dstfileuri = fileTemp.path;
  fs.copyFileSync(srcfile.fd,fileTemp.fd);
  fs.closeSync(srcfile);
  fs.closeSync(fileTemp);
  return dstfileuri;
}