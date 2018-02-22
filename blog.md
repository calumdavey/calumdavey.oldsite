[Home](index.md) | [About](about.md) | [Research](research.md) | [Blog](blog.md) | [Resources](resources.md)

<div class="post"> 
  {% for post in site.posts %}
  {% capture y %}{{post.date | date:"%Y"}}{% endcapture %}
 
    <article class="post">
      <time datetime="{{ post.date | date:"%Y-%m-%d" }}">{{ post.date | date:"%Y-%m-%d" }}</time>
      <h1><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h1>

      <div class="entry">
        {{ post.excerpt }}
      </div>

      <a href="{{ site.baseurl }}{{ post.url }}" class="read-more">Read More</a>
    </article>
  {% endfor %}
</div>
