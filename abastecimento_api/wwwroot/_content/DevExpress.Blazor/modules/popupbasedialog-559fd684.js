import{D as e}from"./data-qa-utils-8be7c726.js";import{n as t,r as s,y as a}from"./lit-element-d284a100.js";class l extends t{static get styles(){return s`
            :host {
                display: flex;
            }
        `}connectedCallback(){super.connectedCallback(),e.setLoaded(this)}disconnectedCallback(){super.disconnectedCallback(),e.removeLoaded(this)}render(){return a`<slot></slot>`}}export{l as D};
