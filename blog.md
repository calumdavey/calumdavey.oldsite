[Home](README.md) | [About](about.md) | [Research](research.md) | [Resources](resources.md)

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>
