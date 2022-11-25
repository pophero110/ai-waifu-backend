// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails';
import './controllers';
import jquery from 'jquery';
import * as bootstrap from 'bootstrap';

window.$ = jquery;

$(window).scroll(function () {
    if ($(document).scrollTop() > 100) {
        $('.navbar').addClass('semi-transparent');
    } else {
        $('.navbar').removeClass('semi-transparent');
    }
});

$('.auth-btn').click(function () {
    $('.sign-up-form').toggleClass('d-none');
    $('.sign-in-form').toggleClass('d-none');
    $('.sign-in-btn').toggleClass('button-toggle');
    $('.sign-up-btn').toggleClass('button-toggle');
});
