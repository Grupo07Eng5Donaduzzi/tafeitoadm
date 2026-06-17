import '../../../core/result/result.dart';
import '../domain/dashboard_models.dart';
import 'dashboard_remote_data_source.dart';

class DashboardRepository {
  const DashboardRepository(this.remoteDataSource);

  final DashboardRemoteDataSource remoteDataSource;

  Future<Result<DashboardSummary>> fetchDashboard() {
    return remoteDataSource.fetchDashboard();
  }
}
