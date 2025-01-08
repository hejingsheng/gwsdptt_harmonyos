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