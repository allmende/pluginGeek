if document.URL.indexOf("https://github.com/") == 0
  open("http://knight.dev/repos/" + document.URL.split("/").slice(3).join("/"))
else
  alert("Please use this bookmarklet on a URL like https://github.com/rails/rails")


###

javascript:(function() {

  if (document.URL.indexOf("https://github.com/") === 0) {
    open("http://knight.dev/repos/" + document.URL.split("/").slice(3).join("/"));
  } else {
    alert("Please use this bookmarklet on a URL like https://github.com/rails/rails");
  }

}).call(this);
###