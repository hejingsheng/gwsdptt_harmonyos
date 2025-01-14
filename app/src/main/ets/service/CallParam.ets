export class PttCallParam {
  public pttId: number;
  public pttName: string;
  public pttType: number;
  public pttCreate: boolean;

  constructor(pttId: number, pttName: string, pttType: number, pttCreate: boolean) {
    this.pttId = pttId;
    this.pttName = pttName;
    this.pttType = pttType;
    this.pttCreate = pttCreate;
  }
}

export class AudioCallParam {
  public remoteId: number;
  public remoteName: string;
  public caller: boolean;

  constructor(remoteId: number, remoteName: string, caller: boolean) {
    this.remoteId = remoteId;
    this.remoteName = remoteName;
    this.caller = caller;
  }

}