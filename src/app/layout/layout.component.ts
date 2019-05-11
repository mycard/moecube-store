import {Component, Inject, LOCALE_ID, OnInit} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {map} from "rxjs/operators";
import yaml from 'yaml';

@Component({
  selector: 'app-layout',
  templateUrl: './layout.component.html',
  styleUrls: ['./layout.component.css']
})
export class LayoutComponent{
  latest_win32 = this.http
      .get('https://cdn01.moecube.com/downloads/latest.yml', { responseType: 'text' })
      .pipe(map(rawData => 'https://cdn01.moecube.com/downloads/' + yaml.parse(rawData).path));

  latest_drawin = this.http
      .get('https://cdn01.moecube.com/downloads/latest-mac.yml', { responseType: 'text' })
      .pipe(map((rawData) => 'https://cdn01.moecube.com/downloads/' + yaml.parse(rawData).path.replace('-mac.zip', '.dmg')));

  latest_current = navigator.platform.match(/Mac/i) ? this.latest_drawin : this.latest_win32;

  stats_signups = this.http
      .get('https://ygobbs.com/admin/dashboard.json', {
        params: { api_key: 'dc7298a754828b3d26b709f035a0eeceb43e73cbd8c4fa8dec18951f8a95d2bc', api_username: 'zh99998' }
      })
      .pipe(map((data: any) => data.global_reports.find(item => item.type === 'signups').total));

  stats_online = this.http.get('https://api.moecube.com/stats/online', { responseType: 'text' }).pipe(
      map(rawText => {
        const doc = new DOMParser().parseFromString(rawText, 'text/xml');
        const node = doc.querySelector('#content > table > tbody > tr:nth-child(2) > td:nth-child(2)');
        return parseInt(node.textContent);
      })
  );

  constructor(private http: HttpClient, @Inject(LOCALE_ID) public locale: string) {}

  setLocale(locale) {
    document.cookie = `locale=${locale}`;
    location.reload();
  }
}
