---
layout: page
permalink: /repositories/
title: software & resources
description: Research software, reproducible experiments, and companion materials for my academic work.
nav: true
nav_order: 5
---

The projects below provide source code, computational experiments, and teaching materials connected to my publications. My complete public profile is available on [GitHub](https://github.com/{{ site.data.repositories.github_profile }}).

{% if site.data.repositories.projects %}
<div class="repositories">
  {% for project in site.data.repositories.projects %}
    {% include repository/repo.liquid project=project %}
  {% endfor %}
</div>
{% endif %}
