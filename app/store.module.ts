import { NgModule }      from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { StoreComponent }  from './store.component';
import {HttpModule} from '@angular/http';

@NgModule({
  imports:      [ BrowserModule, HttpModule ],
  declarations: [ StoreComponent ],
  bootstrap:    [ StoreComponent ]
})
export class StoreModule { }
