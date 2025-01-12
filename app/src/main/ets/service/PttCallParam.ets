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