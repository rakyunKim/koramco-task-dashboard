Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Dashboard (root)
  root "dashboard#show"

  # Members
  resources :members, only: [:index, :new, :create, :edit, :update, :destroy]

  # WIG + Lead Measures
  resources :wigs, only: [:new, :create, :edit, :update, :destroy] do
    resources :lead_measures, only: [:new, :create, :edit, :update, :destroy]
  end

  # Tasks under Lead Measures
  resources :lead_measures, only: [] do
    resources :tasks, only: [:new, :create, :edit, :update, :destroy]
  end

  # Task toggle
  patch "tasks/:id/toggle", to: "tasks#toggle", as: :toggle_task

  # Task import (이전 작업 가져오기)
  get "tasks/import", to: "tasks#import_form", as: :import_tasks
  post "tasks/import", to: "tasks#import_create"
end
