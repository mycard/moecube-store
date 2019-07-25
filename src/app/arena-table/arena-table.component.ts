import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-arena-table',
  templateUrl: './arena-table.component.html',
  styleUrls: ['./arena-table.component.css']
})
export class ArenaTableComponent implements OnInit {
  listOfData: ArenaDeck[] = [];
  loading = true;

  constructor(private http: HttpClient) {}

  async ngOnInit() {
    this.listOfData = await this.http
      .get<ArenaDeck[]>('https://api.mycard.moe/ygopro/analytics/deck/type', {
        params: {
          type: 'day',
          source: 'mycard-athletic'
        }
      })
      .toPromise();
    this.loading = false;
  }
}

interface ArenaDeck {
  count: '661';
  name: '转生炎兽';
  recent_time: '2019-07-15T00:00:00.000Z';
  source: 'mycard-athletic';
  tags: ['转生炎兽-陀螺', '转生炎兽-割草'];
}
