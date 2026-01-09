import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/project_detail_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class ProjectDetailView extends StatefulWidget {
  final String projectId;

  const ProjectDetailView({super.key, required this.projectId});

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectDetailViewModel>().loadProject(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectDetailViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Project Details'),
        ),
        body: Consumer<ProjectDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.project == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null && viewModel.project == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.clearError();
                        viewModel.loadProject(widget.projectId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final project = viewModel.project;
            if (project == null) {
              return const Center(child: Text('Project not found'));
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.loadProject(widget.projectId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.address,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text(
                                  'Status: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                _buildStatusChip(project.status),
                              ],
                            ),
                            if (project.claimNumber != null) ...[
                              const SizedBox(height: 8),
                              Text('Claim Number: ${project.claimNumber}'),
                            ],
                            if (project.insuranceCompany != null) ...[
                              const SizedBox(height: 8),
                              Text('Insurance: ${project.insuranceCompany}'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Milestones Section
                    const Text(
                      'Milestones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (viewModel.milestones.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('No milestones yet'),
                          ),
                        ),
                      )
                    else
                      ...viewModel.milestones.map((milestone) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              milestone.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (milestone.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(milestone.description!),
                                ],
                                const SizedBox(height: 8),
                                _buildStatusChip(milestone.status),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.push(
                                '/milestones/${project.id}/${milestone.id}',
                              );
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: AppTheme.getStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

