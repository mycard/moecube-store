import {Component, OnInit} from '@angular/core';
import {Http, URLSearchParams} from '@angular/http';
import 'rxjs/Rx';
import * as yaml from 'js-yaml';

@Component({
  moduleId: module.id,
  selector: 'store',
  templateUrl: 'store.component.html',
  styleUrls: ['store.component.css'],
})
export class StoreComponent implements OnInit {
  stats: {signups: number; online: number;};
  latest: {win32: {version: string, url: string}, darwin: {version: string, url: string}};

  constructor (private http: Http) {
  }

  async ngOnInit () {

    this.latest = {
      win32: await this.get_latest_win32(),
      darwin: await this.get_latest_darwin()
    };

    this.stats = {
      signups: await this.get_stats_signups(),
      online: await this.get_stats_online()
    };
  }

  async get_latest_win32 () {
    let data = await this.http.get('https://wudizhanche.mycard.moe/downloads/latest.yml').map(response => yaml.safeLoad(response.text())).toPromise();
    data.url = 'https://r.my-card.in/downloads/' + data.path;
    return data;
  }

  async get_latest_darwin () {
    let data = await this.http.get('https://wudizhanche.mycard.moe/downloads/latest-mac.json').map(response => response.json()).toPromise();
    data.url = data.url.replace('-mac.zip', '.dmg').replace('https://wudizhanche.mycard.moe/downloads/', 'https://r.my-card.in/downloads/');
    return data;
  }

  async get_stats_signups () {
    let params = new URLSearchParams();
    params.set('api_key', 'dc7298a754828b3d26b709f035a0eeceb43e73cbd8c4fa8dec18951f8a95d2bc');
    params.set('api_username', 'zh99998');
    let data = await this.http.get('https://ygobbs.com/admin/dashboard.json', {search: params})
      .map(response => response.json()).toPromise();
    return data.global_reports.find((item: any) => item.type === 'signups').total;
  }

  async get_stats_online () {
    let document = await this.http.get('https://chat.mycard.moe/stats/online')
      .map(response => new DOMParser().parseFromString(response.text(), 'text/xml')).toPromise();
    return parseInt(document.querySelector('#content > table > tbody > tr:nth-child(2) > td:nth-child(2)').textContent);
  }
}
