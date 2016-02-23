import {Component, Directive, Input, QueryList,
        ViewContainerRef, TemplateRef, ContentChildren} from 'angular2/core';

@Directive({
  selector: '[ui-pane]'
})

export class UiPane {
  @Input() title: string;

  private _active:boolean = false;
  constructor(public viewContainer: ViewContainerRef,
              public templateRef: TemplateRef) { }

  @Input() set active(active: boolean) {
    if (active == this._active) return;
    this._active = active;
    if (active) {
      this.viewContainer.createEmbeddedView(this.templateRef);
    } else {
      this.viewContainer.remove(0);
    }
  }
  
  get active(): boolean {
    return this._active;
  }
}

@Component({
  selector: 'ui-tabs',
  template: `
    <nav class="navbar navbar-dark bg-inverse">
      <div class="nav navbar-nav">
        <a *ngFor="var pane of panes" class="nav-item nav-link"  (click)="select(pane)" [class.active]="pane.active" href="#">{{pane.title}}</a>
      </div>
    </nav>
    <ng-content></ng-content>
    `,
    styles:['a { cursor: pointer; cursor: hand; }']
})

export class UiTabs {
  @ContentChildren(UiPane) panes: QueryList<UiPane>;
  select(pane: UiPane) {
    this.panes.toArray().forEach((p: UiPane) => p.active = p == pane);
  }
}
