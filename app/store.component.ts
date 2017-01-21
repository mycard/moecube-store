import {Component, OnInit} from '@angular/core';
import {Http, URLSearchParams} from '@angular/http';
import 'rxjs/Rx';

@Component({
  moduleId: module.id,
  selector: 'store',
  templateUrl: 'store.component.html',
  styleUrls: ['store.component.css'],
})
export class StoreComponent implements OnInit {
  signups: number;
  online: number;

  constructor (private http: Http) {
  }

  async ngOnInit () {
    let params = new URLSearchParams();
    params.set('api_key', 'dc7298a754828b3d26b709f035a0eeceb43e73cbd8c4fa8dec18951f8a95d2bc');
    params.set('api_username', 'zh99998');
    let data = await this.http.get('https://ygobbs.com/admin/dashboard.json', {search: params})
      .map(response => response.json()).toPromise();
    this.signups = data.global_reports.find((item: any) => item.type === 'signups').total;

    let document = await this.http.get('https://chat.mycard.moe/stats/online')
      .map(response => new DOMParser().parseFromString(response.text(), 'text/xml')).toPromise();
    this.online = parseInt(document.querySelector('#content > table > tbody > tr:nth-child(2) > td:nth-child(2)').textContent);
  }
}
