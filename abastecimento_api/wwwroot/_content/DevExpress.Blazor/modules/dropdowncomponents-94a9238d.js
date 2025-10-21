import{a as t}from"./_tslib-158249d5.js";import{D as e,a as i,b as r,I as o}from"./popup-77a1ae4b.js";import{B as s}from"./popuproot-4df55582.js";import{ThumbDragStartedEvent as a,ThumbDragDeltaEvent as d,ThumbDragCompletedEvent as h}from"./thumb-ae63786a.js";import{P as n}from"./point-9c6ab88a.js";import{R as l,a as p}from"./rect-2684652a.js";import{L as g,D as c}from"./layouthelper-c2462bd3.js";import{E as m}from"./eventhelper-dec6cde0.js";import{i as b}from"./query-44b9267f.js";import{e as u,n as f}from"./property-ba1fa369.js";import{y as x,n as y,r as v}from"./lit-element-d284a100.js";import{D}from"./popupbasedialog-559fd684.js";import{dxBranchTagName as C}from"./branch-6684bbdd.js";import{D as H,d as S}from"./events-interseptor-b260a35a.js";import"./rafaction-bba7928b.js";import"./transformhelper-3935ca6a.js";import"./positiontracker-9570b24e.js";import"./positiontrackerobserver-5fd93b2c.js";import"./supportcaptureelement-2f30b59b.js";import"./dx-ui-element-4d613bb9.js";import"./data-qa-utils-8be7c726.js";import"./capturemanager-c228e074.js";let R=class extends e{constructor(){super(...arguments),this.dragStart=null,this.dragBounds=null,this.dragStartedHandler=this.handleDragStarted.bind(this),this.dragDeltaHandler=this.handleDragDelta.bind(this),this.dragCompletedHandler=this.handleDragCompleted.bind(this),this.dragWidth=0,this.dragHeight=0,this.dragMaxWidth=0,this.dragMaxHeight=0,this.isInDragOperation=!1,this.dragCssStyle=null}get branchType(){return s.DropDown}renderTemplate(){return x`
            <dxbl-branch
                id="branch"
                branch-id="${this.branchId}"
                parent-branch-id="${this.parentBranchId}"
                type="${this.branchType}"
                style="${this.dragCssStyle}">
                <dxbl-dropdown-root
                    id="root"
                    style="${this.rootCssStyle}"
                    ?resizing="${this.resizing}"
                    drop-opposite="${this.actualDropOpposite}"
                    drop-direction="${this.actualDropDirection}"
                    drop-alignment="${this.actualDropAlignment}">
                    ${this.renderDefaultSlot()}
                    ${this.renderAdditionalSlots()}
                    ${this.renderBridgeSlot()}
                </dxbl-dropdown-root>
            </dxbl-branch>
        `}connectedCallback(){super.connectedCallback(),this.addEventListener(a.eventName,this.dragStartedHandler),this.addEventListener(d.eventName,this.dragDeltaHandler),this.addEventListener(h.eventName,this.dragCompletedHandler)}disconnectedCallback(){super.disconnectedCallback(),this.removeEventListener(a.eventName,this.dragStartedHandler),this.removeEventListener(d.eventName,this.dragDeltaHandler),this.removeEventListener(h.eventName,this.dragCompletedHandler)}get child(){return this.root}handleDragStarted(t){const e=m.getOriginalSource(t);if(!e)return;if(!e.hasAttribute("data-dropdown-thumb"))return;if(!this.child)return;this.lockPlacement(),this.dragStart=new n(t.detail.x,t.detail.y);const i=this.getRestrictBounds(),r=this.getPlacementTargetInterestPoints(this.placement),o=this.actualDropAlignment,s=this.actualDropDirection,a=g.getRelativeElementRect(this.child);this.dragBounds=this.calcResizeRect(i,r,o,s),this.dragMaxWidth=this.dragBounds.width,this.dragMaxHeight=this.dragBounds.height,this.isInDragOperation=!0,this.dragWidth=a.width,this.dragHeight=a.height,this.raiseResizeStarted(this.dragWidth,this.dragHeight)}willUpdate(t){super.willUpdate(t),this.dragCssStyle=this.isInDragOperation?`width: ${c.toPx(this.dragWidth)}; height: ${c.toPx(this.dragHeight)}; max-width: ${c.toPx(this.dragMaxWidth)}; max-height: ${c.toPx(this.dragMaxHeight)};`:null}updated(t){super.updated(t),this.root.offsetWidth<this.root.scrollWidth&&(this.dragWidth=this.root.scrollWidth),this.root.offsetHeight<this.root.scrollHeight&&(this.dragHeight=this.root.scrollHeight)}handleDragDelta(t){const e=m.getOriginalSource(t);e&&e.hasAttribute("data-dropdown-thumb")&&(this.dragWidth=Math.min(this.dragMaxWidth,this.actualDropDirection===i.Near?t.detail.x-this.offset.x:this.offset.x+this.childSize.width-t.detail.x),this.dragHeight=Math.min(this.dragMaxHeight,this.actualDropAlignment===r.bottom?t.detail.y-this.offset.y:this.offset.y+this.childSize.height-t.detail.y))}handleDragCompleted(t){var e,i;const r=m.getOriginalSource(t);r&&r.hasAttribute("data-dropdown-thumb")&&(this.isInDragOperation=!1,this.dragWidth=null!==(e=this.branch.offsetWidth)&&void 0!==e?e:0,this.dragHeight=null!==(i=this.branch.offsetHeight)&&void 0!==i?i:0,this.desiredWidth=c.toPx(this.dragWidth),this.desiredHeight=c.toPx(this.dragHeight),this.unlockPlacement(),this.raiseResizeCompleted(this.dragWidth,this.dragHeight))}calcResizeRect(t,e,s,a){if(a===i.Near){if(s===r.top){return l.intersect(t,p.createFromPoints(e[o.TopLeft],t.topRight))}return l.intersect(t,p.createFromPoints(e[o.BottomLeft],t.bottomRight))}if(s===r.top){return l.intersect(t,p.createFromPoints(e[o.TopRight],t.topLeft))}return l.intersect(t,p.createFromPoints(e[o.BottomRight],t.bottomLeft))}raiseResizeStarted(t,e){this.raiseEvent("resizeStarted",{Width:Math.floor(t),Height:Math.floor(e)})}raiseResizeCompleted(t,e){this.raiseEvent("resizeCompleted",{Width:Math.floor(t),Height:Math.floor(e)})}calcRenderWidth(){return this.isInDragOperation?null:super.calcRenderWidth()}calcRenderHeight(){return this.isInDragOperation?null:super.calcRenderHeight()}shouldUpdateRootCssStyle(t){return super.shouldUpdateRootCssStyle(t)||t.has("isInDragOperation")||t.has("dragWidth")||t.has("dragHeight")||t.has("dragMaxWidth")||t.has("dragMaxHeight")}};t([b("#root",!0)],R.prototype,"root",void 0),t([b("#branch")],R.prototype,"branch",void 0),t([u({type:Number,reflect:!1})],R.prototype,"dragWidth",void 0),t([u({type:Number,reflect:!1})],R.prototype,"dragHeight",void 0),t([u({type:Number,reflect:!1})],R.prototype,"dragMaxWidth",void 0),t([u({type:Number,reflect:!1})],R.prototype,"dragMaxHeight",void 0),t([u({type:Boolean,reflect:!1})],R.prototype,"isInDragOperation",void 0),t([u({type:String,reflect:!1})],R.prototype,"dragCssStyle",void 0),R=t([f("dxbl-dropdown")],R);let w=class extends D{createRenderRoot(){return this}};w=t([f("dxbl-dropdown-dialog")],w);let z=class extends y{constructor(){super(...arguments),this.topLeftClass=null,this.topRightClass=null,this.bottomLeftClass=null,this.bottomRightClass=null,this.dropOpposite=!1,this.dropDirection=i.Near,this.dropAlignment=r.bottom,this.resizing=!1}static get styles(){return v`
            :host {
                display: flex;
                position: relative;
                flex: 1 1 auto;
                flex-direction: column;
                box-sizing: border-box;
                min-height: 0;
            }
            .hidden {
                display: none;
            }
            ::slotted([slot="top-right"]) {
                position: absolute;
                z-index: 1001;
                top: 0px;
                right: 0px;
                transform: rotate(270deg);
                cursor: ne-resize;
            }
            ::slotted([slot="top-left"]) {
                position: absolute;
                z-index: 1001;
                top: 0px;
                left: 0px;
                transform: rotate(180deg);
                cursor: nw-resize;
            }
            ::slotted([slot="bottom-left"]) {
                position: absolute;
                z-index: 1001;
                bottom: 0px;
                left: 0px;
                transform: rotate(90deg);
                cursor: sw-resize;
            }
            ::slotted([slot="bottom-right"]) {
                position: absolute;
                z-index: 1001;
                bottom: 0px;
                right: 0px;
                cursor: se-resize;
                transform: rotate(0deg);
            }
        }`}connectedCallback(){super.connectedCallback(),this.calculateStyles(this.resizing,this.dropAlignment,this.dropDirection)}willUpdate(t){(t.has("dropAlignment")||t.has("dropDirection")||t.has("resizing"))&&this.calculateStyles(this.resizing,this.dropAlignment,this.dropDirection)}calculateStyles(t,e,o){this.topLeftClass=t&&e===r.top&&o===i.Far?null:"hidden",this.topRightClass=t&&e===r.top&&o===i.Near?null:"hidden",this.bottomLeftClass=t&&e===r.bottom&&o===i.Far?null:"hidden",this.bottomRightClass=t&&e===r.bottom&&o===i.Near?null:"hidden"}render(){return x`
            <slot></slot>
            <dxbl-thumb data-qa-thumb-location="top-left" data-dropdown-thumb class="${this.topLeftClass}">
                <slot name="top-left"></slot>
            </dxbl-thumb>
            <dxbl-thumb data-qa-thumb-location="top-right" data-dropdown-thumb class="${this.topRightClass}">
                <slot name="top-right"></slot>
            </dxbl-thumb>
            <dxbl-thumb data-qa-thumb-location="bottom-left" data-dropdown-thumb class="${this.bottomLeftClass}">
                <slot name="bottom-left"></slot>
            </dxbl-thumb>
            <dxbl-thumb data-qa-thumb-location="bottom-right" data-dropdown-thumb class="${this.bottomRightClass}">
                <slot name="bottom-right"></slot>
            </dxbl-thumb>`}};t([u({type:String,reflect:!1})],z.prototype,"topLeftClass",void 0),t([u({type:String,reflect:!1})],z.prototype,"topRightClass",void 0),t([u({type:String,reflect:!1})],z.prototype,"bottomLeftClass",void 0),t([u({type:String,reflect:!1})],z.prototype,"bottomRightClass",void 0),t([u({type:Object,attribute:"drop-opposite"})],z.prototype,"dropOpposite",void 0),t([u({type:String,attribute:"drop-direction"})],z.prototype,"dropDirection",void 0),t([u({type:String,attribute:"drop-alignment"})],z.prototype,"dropAlignment",void 0),t([u({type:Boolean,attribute:"resizing"})],z.prototype,"resizing",void 0),z=t([f("dxbl-dropdown-root")],z);const W=["dxbl-dropdown","dxbl-dropdown-dialog","dxbl-dropdown-root",C,H,S];function j(t){return t}const $={getReference:j,registeredComponents:W};export{$ as default,j as getReference,W as registeredComponents};
