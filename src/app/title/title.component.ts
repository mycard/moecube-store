import { Component, Input, OnInit } from '@angular/core';
import { Title } from '@angular/platform-browser';

@Component({
  selector: 'app-title',
  template: ''
})
export class TitleComponent implements OnInit {

  @Input()
  title: string;
  constructor(private titleService: Title) {}

  ngOnInit() {
    this.titleService.setTitle(this.title);
  }

}
