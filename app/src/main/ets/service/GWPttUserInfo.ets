import { faceDetector } from '@kit.CoreVisionKit';

class CurrentGroup {
  private _gid: number = 0;

  public set gid(value: number) {
    this._gid = value;
  }

  public get gid(): number {
    return this._gid;
  }

  private _gname: string = '';

  public set gname(value: string) {
    this._gname = value;
  }

  public get gname(): string {
    return this._gname;
  }

  private _type: number = 0;

  public set type(value: number) {
    this._type = value;
  }

  public get type(): number {
    return this._type;
  }

  private _priority: number = 0;

  public set priority(value: number) {
    this._priority = value;
  }

  public get priority(): number {
    return this._priority;
  }
}

export class GWPttUserInfo {
  private _account: string = '';

  public set account(value: string) {
    this._account = value;
  }

  public get account(): string {
    return this._account;
  }

  private _password: string = '';

  public set password(value: string) {
    this._password = value;
  }

  public get password(): string {
    return this._password;
  }

  private _name: string = '';

  public set name(value: string) {
    this._name = value;
  }

  public get name(): string {
    return this._name;
  }

  private _id: number = 0;

  public set id(value: number) {
    this._id = value;
  }

  public get id(): number {
    return this._id;
  }

  private _defaultGid: number = 0;

  public set defaultGid(value: number) {
    this._defaultGid = value;
  }

  public get defaultGid(): number {
    return this._defaultGid;
  }

  private _message: boolean = false;

  public set message(value: boolean) {
    this._message = value;
  }

  public get message(): boolean {
    return this._message;
  }

  private _call: boolean = false;

  public set call(value: boolean) {
    this._call = value;
  }

  public get call(): boolean {
    return this._call;
  }

  private _video: boolean = false;

  public set video(value: boolean) {
    this._video = value;
  }

  public get video(): boolean {
    return this._video;
  }

  private _silent: boolean = false;

  public set silent(value: boolean) {
    this._silent = value;
  }

  public get silent(): boolean {
    return this._silent;
  }

  private _currentGroup: CurrentGroup = new CurrentGroup();

  public getCurrentGroupName(): string {
    return this._currentGroup.gname;
  }

  public setCurrentGroupName(value: string) {
    this._currentGroup.gname = value;
  }

  public getCurrentGroupGid(): number {
    return this._currentGroup.gid;
  }

  public setCurrentGroupGid(value: number) {
    this._currentGroup.gid = value;
  }

  public getCurrentGroupPriority(): number {
    return this._currentGroup.priority;
  }

  public setCurrentGroupPriority(value: number) {
    this._currentGroup.priority = value;
  }

  public getCurrentGroupType(): number {
    return this._currentGroup.type;
  }

  public setCurrentGroupType(value: number) {
    this._currentGroup.type = value;
  }

  private _lastpriority: number = 0;

  public set lastpriority(value: number) {
    this._lastpriority = value;
  }

  public get lastpriority(): number {
    return this._lastpriority;
  }

  private _online: boolean = false;

  public set online(value: boolean) {
    this._online = value;
  }

  public get online(): boolean {
    return this._online;
  }


}