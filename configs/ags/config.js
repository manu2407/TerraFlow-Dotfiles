import { Dashboard } from './widget/Dashboard.js';
import { Bar } from './widget/Bar.js';

App.config({
    style: './style.css',
    windows: [
        Bar(0),
        Dashboard(),
    ],
});
