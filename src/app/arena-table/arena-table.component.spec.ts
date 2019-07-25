import { fakeAsync, ComponentFixture, TestBed } from '@angular/core/testing';
import { ArenaTableComponent } from './arena-table.component';

describe('ArenaTableComponent', () => {
  let component: ArenaTableComponent;
  let fixture: ComponentFixture<ArenaTableComponent>;

  beforeEach(fakeAsync(() => {
    TestBed.configureTestingModule({
      declarations: [ ArenaTableComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ArenaTableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  }));

  it('should compile', () => {
    expect(component).toBeTruthy();
  });
});
