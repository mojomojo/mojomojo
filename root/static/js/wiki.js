function cleanAuthorName(author) {
  if (document.getElementById('authorName').value == "") {
    document.getElementById('authorName').value = author;
  }
}

function toggleInfo() {
    state=!state;
    var item=$('hidden_info');
    if (state) {
        item.style.display='block'; 
        item.style.opacity = 0.99999;
        item.style.filter = "alpha(opacity:"+100+")";
    } else {
        new Effect2.Fade('hidden_info',{duration:0.3})
    }
}

var diff='';
function toggleChanges(changeurl) {
  if (!diff) {
      diff=xmlHTTPRequest(changeurl);
      $('diff').innerHTML=diff;
  }
  Toggle.display('changes');
  Toggle.display('current');
  Toggle.display('show_changes');
  Toggle.display('hide_changes');
  /* if ($('changes').style.display == "none") {
    $('changes').style.display  = "block";
    $('current').style.display = "none";
    $('show_changes').style.display  = "none";
    $('hide_changes').style.display = "inline";
  } else {
    $('changes').style.display  = "none";
    $('current').style.display = "block";
    $('show_changes').style.display  = "inline";
    $('hide_changes').style.display = "none";
  }*/
}
