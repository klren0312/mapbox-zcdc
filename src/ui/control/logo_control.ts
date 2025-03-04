import * as DOM from '../../util/dom';
import {bindAll} from '../../util/util';

import type {Map, IControl} from '../map';

/**
 * A `LogoControl` is a control that adds the Mapbox watermark
 * to the map as required by the [terms of service](https://www.mapbox.com/tos/) for Mapbox
 * vector tiles and core styles.
 * Add this control to a map using {@link Map#addControl}.
 *
 * @implements {IControl}
 * @private
**/

class LogoControl implements IControl {
    _map: Map;
    _container: HTMLElement;

    constructor() {
        bindAll(['_updateLogo', '_updateCompact'], this);
    }

    onAdd(map: Map): HTMLElement {
        this._map = map;
        this._container = DOM.create('div', 'mapboxgl-ctrl');
        this._container.style.display = 'none';

        return this._container;
    }

    onRemove() {
        this._container.remove();
    }

}

export default LogoControl;
