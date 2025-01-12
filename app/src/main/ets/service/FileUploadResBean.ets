export class FileUrl {
  public url:string;
  public fileId:string;

  constructor(url: string, fileId: string) {
    this.url = url;
    this.fileId = fileId;
  }

}

export class FileResult {
  public file1:FileUrl|undefined;
  public file2:FileUrl|undefined;

  constructor(file1: FileUrl|undefined, file2: FileUrl|undefined) {
    this.file1 = file1;
    this.file2 = file2;
  }
}

export class FileUploadResBean {
  public status:number;
  public message:string;
  public total:number;
  public pages:number;
  public data:FileResult|undefined;

  constructor(status: number, message: string, total: number, pages: number, data: FileResult|undefined) {
    this.status = status;
    this.message = message;
    this.total = total;
    this.pages = pages;
    this.data = data;
  }

}