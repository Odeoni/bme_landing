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

  $form['sciencecampus_text']['felveteli_heading'] = [
    '#type' => 'textfield',
    '#title' => t('Felvételi pont szekció címe'),
    '#description' => t('A "Mit kapsz diákként?" szekció alatti, felvételi pontokra felhívó cím szövege.'),
    '#default_value' => theme_get_setting('felveteli_heading') ?: 'Szerezz 15 intézményi felvételi pontot a Science Campus programokkal!',
    '#maxlength' => 255,
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
