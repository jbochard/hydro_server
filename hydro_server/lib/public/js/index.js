var snapper = new Snap({
            element: document.getElementById('content'),
            dragger: document.getElementById('do-drag'),
            disable: 'right',
            hyperextensible: false
        });
document.getElementById('search').addEventListener('focus', function(){
    snapper.expand('left');
});

document.getElementById('search').addEventListener('blur', function(){
    snapper.open('left');
});
