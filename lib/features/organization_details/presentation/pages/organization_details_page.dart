import 'package:curejobs/shared/widgets/separation_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../../all_jobs/domain/entities/job_feed.dart';
import '../../../all_jobs/presentation/bloc/jobs_bloc.dart';
import '../../../all_jobs/presentation/widgets/job_card.dart';
import '../../../apply_job/presentation/widgets/apply_flow_widgets.dart';
import '../../../job_details/presentation/pages/job_details_page.dart';
import '../../domain/entities/organization_details.dart';
import '../bloc/organization_details_cubit.dart';
import '../widgets/organization_details_sections.dart';

/// An employer's public profile with its open jobs below.
class OrganizationDetailsPage extends StatelessWidget {
  const OrganizationDetailsPage({super.key, required this.slug, this.name});

  /// Slug (or id) used in `api/v1/public/organizations/{slug}`.
  final String slug;

  /// Shown in the app bar while loading.
  final String? name;

  /// Opens the employer of [organization]; uses its slug when the API sent
  /// one, otherwise its id.
  static Route<void> route(JobOrganization organization) => MaterialPageRoute(
    builder: (_) => OrganizationDetailsPage(
      slug: (organization.slug?.isNotEmpty ?? false)
          ? organization.slug!
          : organization.id,
      name: organization.name,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrganizationDetailsCubit>()..load(slug),
      child: _OrganizationDetailsView(page: this),
    );
  }
}

class _OrganizationDetailsView extends StatelessWidget {
  const _OrganizationDetailsView({required this.page});

  final OrganizationDetailsPage page;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizationDetailsCubit, OrganizationDetailsState>(
      builder: (context, state) {
        final org = state.organization;
        return Scaffold(
          backgroundColor: ApplyFlowColors.page(context),
          appBar: ApplyStepAppBar(
            title: 'Employer details',
            subtitle: org?.name ?? page.name,
          ),
          body: switch (state) {
            OrganizationDetailsState(:final organization?) =>
              // The employer's jobs, filtered by its id via all_jobs.
              BlocProvider(
                key: ValueKey(organization.id),
                create: (_) =>
                    sl<JobsBloc>(param1: JobFeed.all, param2: organization.id)
                      ..add(const JobsRequested()),
                child: _Content(
                  org: organization,
                  logoUrl: state.logoUrl,
                  slug: page.slug,
                ),
              ),
            OrganizationDetailsState(
              status: OrganizationStatus.failure,
              :final failure?,
            ) =>
              AppErrorView(
                failure: failure,
                onRetry: () =>
                    context.read<OrganizationDetailsCubit>().load(page.slug),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.org, required this.slug, this.logoUrl});

  final OrganizationDetails org;
  final String slug;
  final String? logoUrl;

  Future<void> _refresh(BuildContext context) async {
    final jobs = context.read<JobsBloc>()..add(const JobsRequested());
    await Future.wait([
      context.read<OrganizationDetailsCubit>().load(slug),
      jobs.stream.firstWhere((s) => s.status != JobsStatus.loading),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) {
          context.read<JobsBloc>().add(const JobsNextPageRequested());
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: BlocBuilder<JobsBloc, JobsState>(
          builder: (context, jobs) => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: OrganizationHeader(org: org, logoUrl: logoUrl),
              ),
              if (org.description case final d? when d.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SectionBand()),
                SliverToBoxAdapter(
                  child: OrganizationAboutSection(description: d),
                ),
              ],
              const SliverToBoxAdapter(child: SectionBand()),
              SliverToBoxAdapter(
                child: OrganizationJobsHeader(
                  total: jobs.status == JobsStatus.success ? jobs.total : null,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              ..._jobSlivers(context, jobs),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _jobSlivers(BuildContext context, JobsState jobs) {
    const loader = SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    if (jobs.isInitialLoading) return const [loader];

    if (jobs.status == JobsStatus.failure && jobs.jobs.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  jobs.errorMessage ?? 'Could not load jobs.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      context.read<JobsBloc>().add(const JobsRequested()),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (jobs.jobs.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No open jobs right now.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      SliverList.separated(
        itemCount: jobs.jobs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final job = jobs.jobs[i];
          return JobCard(
            job: job,
            onTap: () => Navigator.of(context).push(JobDetailsPage.route(job)),
          );
        },
      ),
      if (jobs.isLoadingMore) loader,
    ];
  }
}
