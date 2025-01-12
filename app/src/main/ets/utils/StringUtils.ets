import util from '@ohos.util';

class StringUtils {
  /**
   * string转Uint8Array
   * @param value
   * @returns
   */
  string2Uint8Array1(value: string): Uint8Array|null {
    if (!value) return null;
    //
    let textEncoder = new util.TextEncoder();
    //获取点流并发出 UTF-8 字节流 TextEncoder 的所有实例仅支持 UTF-8 编码
    return textEncoder.encodeInto(value)
  }

  /**
   * Uint8Array 转  String
   * @param input
   */
  uint8Array2String(input: Uint8Array) : string {
    let decoder = util.TextDecoder.create('utf-8');
    let str = decoder.decodeToString(input);
    return str;
  }
  /**
   * ArrayBuffer 转  String
   * @param input
   * @returns
   */
  arrayBuffer2String(input: ArrayBuffer): string {
    let decoder = util.TextDecoder.create('utf-8');
    let str = decoder.decodeToString(new Uint8Array(input));
    return str;
  }
}

export default new StringUtils()