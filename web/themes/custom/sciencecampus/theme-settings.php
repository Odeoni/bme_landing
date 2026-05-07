<?php

/**
 * @file
 * Theme settings form for Science Campus theme.
 */

use Drupal\file\Entity\File;

/**
 * Implements hook_form_system_theme_settings_alter().
 */
function sciencecampus_form_system_theme_settings_alter(&$form, \Drupal\Core\Form\FormStateInterface $form_state) {

  $form['sciencecampus_text'] = [
    '#type' => 'details',
    '#title' => t('Weboldal szövegek'),
    '#description' => t('Szerkeszthető szövegek a kezdőlapon.'),
    '#open' => TRUE,
  ];

  $form['sciencecampus_text']['programjaink_intro_text'] = [
    '#type' => 'textarea',
    '#title' => t('"Science Campus Programjaink" szekció bevezetője'),
    '#description' => t('A "Science Campus Programjaink" cím alatt megjelenő rövid szöveg, ami a "p" badge mellett áll.'),
    '#default_value' => theme_get_setting('programjaink_intro_text') ?: 'Vegyél részt a pöttyel ellátott programokon, és szerezz intézményi felvételi pontokat.',
    '#rows' => 2,
  ];

  $form['sciencecampus_images'] = [
    '#type' => 'details',
    '#title' => t('Weboldal képek'),
    '#description' => t('A fejléc és lábléc képeinek feltöltése.'),
    '#open' => TRUE,
  ];

  $form['sciencecampus_images']['sc_logo'] = [
    '#type' => 'managed_file',
    '#title' => t('Science Campus logó (fejléc)'),
    '#description' => t('A fejlécben megjelenő Science Campus logó. Ajánlott: PNG, átlátszó háttérrel.'),
    '#default_value' => theme_get_setting('sc_logo') ? [theme_get_setting('sc_logo')] : [],
    '#upload_location' => 'public://theme-images/',
    '#upload_validators' => [
      'file_validate_extensions' => ['png jpg jpeg gif svg webp'],
      'file_validate_size' => [2 * 1024 * 1024],
    ],
  ];

  $form['sciencecampus_images']['bme_logo'] = [
    '#type' => 'managed_file',
    '#title' => t('BME logó (fejléc)'),
    '#description' => t('A fejléc jobb oldalán megjelenő BME logó.'),
    '#default_value' => theme_get_setting('bme_logo') ? [theme_get_setting('bme_logo')] : [],
    '#upload_location' => 'public://theme-images/',
    '#upload_validators' => [
      'file_validate_extensions' => ['png jpg jpeg gif svg webp'],
      'file_validate_size' => [2 * 1024 * 1024],
    ],
  ];

  $form['sciencecampus_social'] = [
    '#type' => 'details',
    '#title' => t('Lábléc közösségi média linkek'),
    '#description' => t('A láblécben megjelenő közösségi média ikonok URL-jei. Hagyd üresen, ha az adott ikon ne jelenjen meg.'),
    '#open' => TRUE,
  ];

  $form['sciencecampus_social']['youtube_url'] = [
    '#type' => 'url',
    '#title' => t('YouTube URL'),
    '#default_value' => theme_get_setting('youtube_url') ?: 'https://www.youtube.com/@BMETTK_1998',
    '#placeholder' => 'https://www.youtube.com/@BMETTK_1998',
  ];

  $form['sciencecampus_social']['facebook_url'] = [
    '#type' => 'url',
    '#title' => t('Facebook URL'),
    '#default_value' => theme_get_setting('facebook_url') ?: 'https://www.facebook.com/BME.TTK.ScienceCampus',
    '#placeholder' => 'https://www.facebook.com/BME.TTK.ScienceCampus',
  ];

  $form['sciencecampus_social']['instagram_url'] = [
    '#type' => 'url',
    '#title' => t('Instagram URL'),
    '#default_value' => theme_get_setting('instagram_url') ?: 'https://www.instagram.com/science_campus_bme_ttk/',
    '#placeholder' => 'https://www.instagram.com/science_campus_bme_ttk/',
  ];

  $form['sciencecampus_images']['campus_map'] = [
    '#type' => 'managed_file',
    '#title' => t('Campus térkép (lábléc)'),
    '#description' => t('A láblécben megjelenő campus térkép kép.'),
    '#default_value' => theme_get_setting('campus_map') ? [theme_get_setting('campus_map')] : [],
    '#upload_location' => 'public://theme-images/',
    '#upload_validators' => [
      'file_validate_extensions' => ['png jpg jpeg gif svg webp'],
      'file_validate_size' => [5 * 1024 * 1024],
    ],
  ];

  // Add submit handler to make uploaded files permanent.
  $form['#submit'][] = 'sciencecampus_settings_submit';
}

/**
 * Submit handler: mark uploaded files as permanent.
 */
function sciencecampus_settings_submit(&$form, \Drupal\Core\Form\FormStateInterface $form_state) {
  $image_fields = ['sc_logo', 'bme_logo', 'campus_map'];

  foreach ($image_fields as $field) {
    $value = $form_state->getValue($field);
    if (!empty($value[0])) {
      $file = File::load($value[0]);
      if ($file) {
        $file->setPermanent();
        $file->save();
        // Store only the file ID.
        $form_state->setValue($field, $value[0]);
      }
    }
    else {
      $form_state->setValue($field, '');
    }
  }
}
