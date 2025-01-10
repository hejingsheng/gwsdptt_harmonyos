import dayJs from 'dayjs'
import customParseFormat from "dayjs/plugin/customParseFormat"
import isLeapYear from "dayjs/plugin/isLeapYear"
import isSameOrBefore from "dayjs/plugin/isSameOrBefore"
import isSameOrAfter from "dayjs/plugin/isSameOrAfter"
/**
 * 时间工具类
 */
dayJs.extend(customParseFormat)
dayJs.extend(isLeapYear)
dayJs.extend(isSameOrBefore)
dayJs.extend(isSameOrAfter)

class TimeUtils {

  /**
   * 获取系统当前时间时间戳
   * @returns
   */
  getSystemTimeMillis(): number {
    return new Date().getTime()
  }

  /**
   * 获取时间戳
   * @param time
   * @returns
   */
  getTimeMillis(time: string | number | Date): number {
    return dayJs(time).valueOf()
  }

  /**
   * 通过时间戳获取Date
   * @param timeMillis
   * @returns
   */
  getDate(timeMillis:number):Date{
    return new Date(timeMillis)
  }

  /**
   * 获取当前时间，格式：2023-10-12 16:66:66
   * @returns
   */
  getNowTime(): string {
    return dayJs().year() + "-" + dayJs().month() + "-" + dayJs().day() + " " + dayJs().hour() + ":" + dayJs()
      .minute() + ":" + dayJs().second()
  }

  /**
   * 时间格式化，格式：YYYY-MM-DD HH:mm:ss
   * @param time
   */
  formatFullTime(time: string | number | Date): string {
    return dayJs(time).format("YYYY-MM-DD HH:mm:ss")
  }

  /**
   * 时间格式化，格式：YYYY-MM-DD
   * @param time
   */
  formatDate(time: string | number | Date): string {
    return  dayJs(time).format("YYYY-MM-DD")
  }

  /**
   * 时间格式化，格式：HH:mm:ss
   * @param time
   */
  formatTime(time: string | number | Date): string {
    return  dayJs(time).format("HH:mm:ss")
  }

  /**
   * 时间格式化，格式：YYYY-MM-DD HH:mm:ss
   * @param time
   */
  formatDateTime(time: string | number | Date, format:string): string {
    return  dayJs(time).format(format)
  }

  /**
   * 获取往前一天日期
   */
  getLastDay(time: string | number | Date):string {
    return  dayJs(time).subtract(1, "day").toString()
  }

  /**
   * 获取往后一天日期
   */
  getNextDay(time: string | number | Date):string  {
    return  dayJs(time).add(1, "day").toString()
  }

  /**
   * 是否是闰年
   * @param time
   * @returns
   */
  isLeapYear(time: string | number | Date):boolean {
    return dayJs(time).isLeapYear()
  }

  /**
   * 判断一个时间是否和一个时间相同或在一个时间之前。
   * @param time
   * @returns
   */
  isSameOrBefore(time: string | number | Date,newTime:string | number | Date):boolean {
    return dayJs(newTime).isSameOrBefore(time)
  }
  /**
   * 判断一个时间是否和一个时间相同或在一个时间之后。
   * @param time
   * @returns
   */
  isSameOrAfter(time: string | number | Date,newTime:string | number | Date):boolean {
    return dayJs(newTime).isSameOrAfter(time)
  }
}

export default new TimeUtils()
