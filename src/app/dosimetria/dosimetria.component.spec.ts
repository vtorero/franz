import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DosimetriaComponent } from './dosimetria.component';

describe('DosimetriaComponent', () => {
  let component: DosimetriaComponent;
  let fixture: ComponentFixture<DosimetriaComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DosimetriaComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DosimetriaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
