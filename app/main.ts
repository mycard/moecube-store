window['jQuery'] = require('jquery');
window['Tether'] = require('tether');
import 'bootstrap';
import {platformBrowserDynamic} from '@angular/platform-browser-dynamic';
import {StoreModule} from './store.module';

platformBrowserDynamic().bootstrapModule(StoreModule);
