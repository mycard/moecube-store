import {platformBrowser} from '@angular/platform-browser';
import {StoreModuleNgFactory} from '../aot/app/store.module.ngfactory';
import {enableProdMode} from '@angular/core';

enableProdMode();
platformBrowser().bootstrapModuleFactory(StoreModuleNgFactory);
