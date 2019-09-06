---
layout: home
---
<style type="text/css">
.app-icon {
    float: left;
    width: 200px;
    min-height: 108px;
    padding: 20px;
    text-align: center;    
}
</style>
{% for app in site.apps %}
{%- assign data = site.data.apps[app.slug] -%}
    <a href="{{ app.url }}" class="app-icon">
        <img src="{{ data.artworkUrl60}}" alt="{{ app.title}}s app icon"><br>
        {{ app.title }}
    </a>
{% endfor %}

