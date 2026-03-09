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

  # Goals + Tasks (작업)
  resources :wigs, only: [:new, :create, :edit, :update, :destroy] do
    resources :lead_measures, only: [:new, :create, :edit, :update, :destroy]
  end

  # To-dos (할 일) under Tasks (작업)
  resources :lead_measures, only: [] do
    resources :tasks, only: [:new, :create, :edit, :update, :destroy]
  end

  # Move task to current week
  patch "lead_measures/:id/move_to_current_week", to: "lead_measures#move_to_current_week", as: :move_lead_measure_to_current_week

  # Task toggle
  patch "tasks/:id/toggle", to: "tasks#toggle", as: :toggle_task

  # Task import (이전 할 일 가져오기)
  get "tasks/import", to: "tasks#import_form", as: :import_tasks
  post "tasks/import", to: "tasks#import_create"
end
