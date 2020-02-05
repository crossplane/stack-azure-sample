/*

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controllers

import (
	"github.com/crossplaneio/resourcepacks/pkg/controllers"
	"reflect"

	"github.com/go-logr/logr"
	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"

	"github.com/crossplaneio/stack-minimal-azure/api/v1alpha1"
)

// MinimalAzureReconciler reconciles a MinimalAzure object
type MinimalAzureReconciler struct {
	client.Client
	Log    logr.Logger
	Scheme *runtime.Scheme
}

var (
	MinimalAzureKind             = reflect.TypeOf(v1alpha1.MinimalAzure{}).Name()
	MinimalAzureKindAPIVersion   = MinimalAzureKind + "." + v1alpha1.GroupVersion.String()
	MinimalAzureGroupVersionKind = v1alpha1.GroupVersion.WithKind(MinimalAzureKind)
)

// +kubebuilder:rbac:groups=azure.resourcepacks.crossplane.io,resources=minimalazures,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=azure.resourcepacks.crossplane.io,resources=minimalazures/status,verbs=get;update;patch

func (r *MinimalAzureReconciler) SetupWithManager(mgr ctrl.Manager) error {
	csr := controllers.NewResourcePackReconciler(mgr, MinimalAzureGroupVersionKind)
	return ctrl.NewControllerManagedBy(mgr).
		For(&v1alpha1.MinimalAzure{}).
		Complete(csr)
}
