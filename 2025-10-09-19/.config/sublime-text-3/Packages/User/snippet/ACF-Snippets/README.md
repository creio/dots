# Sublime ACF (Advanced Custom Fields) Snippets

The atom version of this package is available at [smilledge/acf-atom-snippets](https://github.com/smilledge/acf-atom-snippets).

## Installation

Clone this repo into your Sublime packages folder. (You may need to update the path if you are using Sublime Text 3)

### Mac
```
git clone https://github.com/smilledge/acf-sublime-snippets.git ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User/ACF-Snippets
```

### Linux
```
git clone https://github.com/smilledge/acf-sublime-snippets.git ~/.config/sublime-text-2/Packages/User/ACF-Snippets
```

### Windows
```
git clone https://github.com/smilledge/acf-sublime-snippets.git [user]\AppData\Roaming\Sublime Text 2\Packages\User\ACF-Snippets
```


## Snippets

All tab triggers follow the following naming convention; `field:{field type}:{type/option}`. All fields also have appropriate tabstops setup, however the first will always be the field name.

### Basic Fields

`field` / `field:header` / `field:text` / `field:link` / `field:option` **(HTML/PHP)**

Get a field by name. (Header / text / link fields will be wrapped in `<h*>` / `<p>` / `<a>` tags)

```
<?$php if ( get_field('field_name') ) : ?>
  <?$php echo get_field('field_name'); ?>
<?$php endif; ?>
```

**`field:date` (HTML)**

Get and format a date field

```
<?php if ( get_field('field_name') ) : $date = DateTime::createFromFormat('Ymd', get_field('field_name')); ?>
  <?php echo $date->format('d-m-Y'); ?>
<?php endif; ?>
```

**`field:if` / `field:ifelse` (HTML)**

Field conditional. Also used for true/false fields.

```
<?php if ( get_field('field_name') ) : ?>
<?php endif; ?>
```

### Image Field

**`field:image` (HTML)**

Image field with a return value of "Image URL"

```
<?php if ( get_field('field_name') ) : ?>
    <img src="<?php the_field('field_name'); ?>" alt="<?php the_field(''); ?>">
<?php endif; ?>
```

**`field:image:id` (HTML)**

Image field with a return value of "Image ID"

```
<?php
if ( get_field('field_name') ) {
  $attachment_id = get_field('field_name');
  $size = "full"; // (thumbnail, medium, large, full or custom size)
  wp_get_attachment_image( $attachment_id, $size );
}
?>
```

**`field:image:object` (HTML)**

Image field with a return value of "Image Object"

```
<?php if ( get_field('field_name') ) : $image = get_field('field_name'); ?>

  <!-- Full size image -->
  <img src="<?php echo $image['url']; ?>" alt="<?php echo $image['alt']; ?>"/>

  <!-- Thumbnail image -->
  <img src="<?php echo $image['sizes']['thumbnail']; ?>" alt="<?php echo $image['alt']; ?>"/>

<?php endif; ?>
```
### File Field

**`field:file` (HTML)**

File field with a return value of "File URL"

```
<?php if ( get_field('field_name') ) : ?>
  <a href="<?php the_field('field_name'); ?>" >Download File</a>
<?php endif; ?>
```

**`field:file:id` (HTML)**

File field with a return value of "File ID"

```
<?php
  if ( get_field('field_name') ) :
    $attachment_id = get_field('field_name');
    $url = wp_get_attachment_url( $attachment_id );
    $title = get_the_title( $attachment_id );
?>
  <a href="<?php echo $url; ?>" ><?php echo $title; ?></a>
<?php endif; ?>
```

**`field:file:object` (HTML)**

File field with a return value of "File Object"

```
<?php if ( get_field('field_name') ) : $file = get_field('field_name'); ?>
  <a href="<?php echo $file['url']; ?>"><?php echo $file['title']; ?></a>
<?php endif; ?>
```
### Relationship Field

**`field:relationship` (HTML)**

Get a relationship field and loop over all returned posts.
```
<?php $posts = get_field('field_name'); ?>
<?php if ( $posts ): ?>
  <ul>
    <?php foreach ( $posts as $post ) : setup_postdata( $post ); ?>
      <li>
        <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
      </li>
    <?php endforeach; wp_reset_postdata(); ?>
  </ul>
<?php endif; ?>
```

### Location Field

**`field:location` (HTML)**

Get the street address from a location field

```
<?php if ( get_field('field_name') ) :
  $location = get_field('field_name'); ?>
  <?php echo $location['address']; ?>
<?php endif; ?>
```

**`field:location:staticmap` (HTML)**

Get a location field and convert it to a static Google Map

```
<?php if ( get_field('field_name') ) :
  $location = get_field('field_name');
  $coordinates = isset( $location['coordinates'] ) ? $location['coordinates'] : $location ; ?>
  <img src="http://maps.google.com/maps/api/staticmap?markers=<?php echo $coordinates; ?>&size=500x300&sensor=false" alt="">
<?php endif; ?>
```

**`field:location:map` (HTML)**

Get a location field and convert it to an interactive Google Map. Also adds a marker to the location. The CSS is used to prevent rendering issues with map controls caused by most responsive CSS grids.

```
<?php if ( get_field('field_name') ) :
  $location = get_field('field_name');
  $coordinates = isset( $location['coordinates'] ) ? $location['coordinates'] : $location ; ?>

  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false"></script>
  <script>
    google.maps.event.addDomListener(window, 'load', function() {
      var map = new google.maps.Map(document.getElementById('map-canvas'), {
        zoom: 16,
        center: new google.maps.LatLng(<?php echo $coordinates; ?>),
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        scrollwheel: false
      });

      new google.maps.Marker({
          position: new google.maps.LatLng(<?php echo $coordinates; ?>),
          map: map
      });
    });
  </script>

  <style>
  #map-canvas img {
    max-width: inherit;
  }
  </style>

  <div id="map-canvas" style="width:500px;height:300px;"></div>

<?php endif; ?>
```

### Gravity Form Field

**`field:form` (HTML)**

Display a gravity form. The parameters for `gravity_form()` are outlined in the [Gravity Forms documentation](http://www.gravityhelp.com/documentation/page/Embedding_A_Form#Function_Call).

```
<?php if ( get_field('field_name') ) {
  $form = get_field('field_name');
  gravity_form_enqueue_scripts($form->id, true);
  gravity_form($form->id, display_title, display_description, false, field_values, enable_ajax, 1);
} ?>
```


### Repeater Field

**`field:repeater` (HTML)**

Get and loop over a repeater field

```
<?php if ( have_rows('field_name') ) : ?>

  <?php while( have_rows('field_name') ) : the_row(); ?>

    <?php the_sub_field('sub_field_name'); ?>

  <?php endfor; ?>

<?php endif; ?>
```

**`field:repeater:grid` (HTML)**

Loop over a repeater filed and seperate results into rows. The second tabstop is the row length.

```
<?php if ( get_field('field_name') ) : ?>

  <div class="items">
    <?php foreach ( array_chunk(get_field('field_name'), 2) as $row): ?>

      <div class="row">
        <?php foreach ($row as $item): ?>

          <div class="item">
            <?php echo $item['field_name']; ?>$5
          </div>

        <?php endforeach; ?>
      </div>

    <?php endforeach; ?>
  </div>

<?php endif; ?>
```

### Queries

**`field:query` (HTML)**

Query a post type on a field value and loop over posts

```
<?php

$args = array(
  'numberposts' => 10,
  'post_type' => 'post',
  'meta_key' => 'field_name',
  'meta_value' => 'field_value'
);

$query = new WP_Query( $args );

?>

<?php if( $query->have_posts() ) : ?>
  <ul>
  <?php while ( $query->have_posts() ) : $query->the_post(); ?>
    <li>
      <a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>
    </li>
  <?php endwhile; ?>
  </ul>
<?php endif; ?>

<?php wp_reset_query(); ?>
```


### Misc

`ddfield` **(HTML/PHP)**

`var_dump` the field contents wrapped in `<pre>` tags.

```
<pre>
    <?php var_dump(get_field('field_name')); die(); ?>
</pre>
```
